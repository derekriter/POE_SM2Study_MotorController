#include "util.hpp"

#include <errno.h>
#include "hardware.hpp"

bool startsWith(char const * const str, char const * const prefix) {
    return strncmp(prefix, str, strlen(prefix)) == 0;
}
bool startsWithP(char const * const str, __FlashStringHelper const * const prefixP) {
    return strncmp_P(str, (char const * const) prefixP, strlen_P((char const * const) prefixP)) == 0;
}
int sign(double val) {
    return val == 0 ? 0 : (val < 0 ? -1 : 1);
}
bool parseDouble(char const * const str, double* const out, char** const end) {
    char* parsedEnd;
    double parsed = strtod(str, &parsedEnd);
    
    //https://forum.arduino.cc/t/how-to-detect-conversion-error-in-strtod/42882/6
    if(parsedEnd == str) return false;
    
    *out = parsed;
    *end = parsedEnd;
    return true;
}
bool parseUInt(char const * const str, uint8_t* const out, char** const end) {
    char* parsedEnd;
    uint8_t parsed = (uint8_t) strtoul(str, &parsedEnd, 10);
    
    if(parsedEnd == str) return false;
    
    *out = parsed;
    *end = parsedEnd;
    return true;
}
double calcPIDS(double currentVal, double target, struct SlotConfig const * config, unsigned long deltaMicros, double* lastError, double* pFactor, double* iFactor, double* iAccum, double* dFactor, double* sFactor) {
    double err = target - currentVal;
    
    *iAccum = min(max(*iAccum + err, -1 / config->kI), 1 / config->kI); //prevent integral windup
    
    double p = config->kP * err;
    double i = config->kI * *iAccum;
    double d;
    if(deltaMicros == 0) {
        d = 0; //prevent divide by zero
    }
    else {
        d = config->kD * (err - *lastError) / deltaMicros * 1e6;
    }
    
    /*
    From Phoenix 6 Slot0Configs.StaticFeedforwardSign:
    
    "The default behavior uses the velocity reference sign. This works well with velocity closed loop, Motion Magic® controls, and position closed loop when velocity reference is specified (motion profiling).

However, when using position closed loop with zero velocity reference (no motion profiling), the application may want to apply static feedforward based on the sign of closed loop error instead. When doing so, we recommend using the minimal amount of kS, otherwise the motor output may dither when closed loop error is near zero."
    */
    int sPolarity;
    switch(config->kSMode) {
        default:
        case KS_MODE_ERROR_BASED: {
            sPolarity = sign(err);
            break;
        }
        case KS_MODE_VELOCITY_BASED: {
            sPolarity = sign(getEncoderTicksPerSecond());
            break;
        }
    }
    double s = config->kS * sPolarity;
    
    *lastError = err;
    *pFactor = p;
    *iFactor = i;
    *dFactor = d;
    *sFactor = s;
    return p + i + d + s;
}
