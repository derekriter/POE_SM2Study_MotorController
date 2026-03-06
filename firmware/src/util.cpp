#include "util.hpp"

#include <errno.h>

bool startsWith(char const * const str, char const * const prefix) {
    return strncmp(prefix, str, strlen(prefix)) == 0;
}
bool startsWithP(char const * const str, __FlashStringHelper const * const prefixP) {
    return strncmp_P(str, (char const * const) prefixP, strlen_P((char const * const) prefixP)) == 0;
}
int sign(float val) {
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
double calcPIDS(double currentVal, double target, struct SlotConfig const * config, unsigned long deltaMicros, double lastErr, double* errOut, double* pOut, double* iOut, double* iAccum, double* dOut, double* sOut) {
    *errOut = target - currentVal;
    
    *pOut = config->kP * *errOut;
    *iOut = config->kI * *iAccum;
    if(deltaMicros == 0) {
        *dOut = 0; //prevent divide by zero
    }
    else {
        *dOut = config->kD * (*errOut - _lastPIDError) / deltaMicros * 1e6;
    }
    
    _iAccumlated = min(max(_iAccumlated + error, -1 / kI), 1 / kI); //prevent integral windup
    _lastPIDError = error;
    
    float pid = p + i + d;
    float kSRef;
    
    /*
    From Phoenix 6 Slot0Configs.StaticFeedforwardSign:
    
    "The default behavior uses the velocity reference sign. This works well with velocity closed loop, Motion Magic® controls, and position closed loop when velocity reference is specified (motion profiling).

However, when using position closed loop with zero velocity reference (no motion profiling), the application may want to apply static feedforward based on the sign of closed loop error instead. When doing so, we recommend using the minimal amount of kS, otherwise the motor output may dither when closed loop error is near zero."
    */
    switch(kSMode) {
        default:
        case KS_MODE_ERROR: {
            kSRef = error;
        }
        case KS_MODE_VELOCITY: {
            kSRef = getEncoderTicksPerSecond();
        }
    }
    return pid + kS * sign(kSRef);
}
