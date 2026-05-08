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
double calcPID(double currentVal, double target, struct SlotConfig const * config, unsigned long deltaMicros, double* lastError, double* pFactor, double* iFactor, double* iAccum, double* dFactor) {
    double err = target - currentVal;
    
    *iAccum += err;
    if(config->kI != 0) {
        *iAccum = min(max(*iAccum, -1 / config->kI), 1 / config->kI); //prevent integral windup
    }
    
    double p = config->kP * err;
    double i = config->kI * *iAccum;
    double d;
    if(deltaMicros == 0) {
        d = 0; //prevent divide by zero
    }
    else {
        d = config->kD * (err - *lastError) / deltaMicros * 1e6;
    }
    
    *lastError = err;
    *pFactor = p;
    *iFactor = i;
    *dFactor = d;
    return p + i + d;
}
double calcTrapProfile(unsigned long microsSinceStart, double startPos, double targetPos, struct SlotConfig const * config, double* secsToCompletion, uint8_t* phase, double* targetVel) {
    //https://www.desmos.com/calculator/1rzl2ysfkp
    
    if(config->aStart <= 0.0 || config->aEnd <= 0.0 || config->vMax <= 0.0) {
        *secsToCompletion = NAN;
        *phase = 255u;
        return startPos;
    }
    
    double minsSinceStart = microsSinceStart / (double) 1e6 / 60.0;
    double deltaPos = targetPos - startPos;
    
    double maxVel = sign(deltaPos) * min(sqrt(2 * abs(deltaPos) / (1 / config->aStart + 1 / config->aEnd)), config->vMax);
    if(maxVel == 0) {
        *secsToCompletion = NAN;
        *phase = 255u;
        *targetVel = 0;
        return startPos;
    }
    
    double tAccel = abs(maxVel) / config->aStart;
    double posAccel = tAccel * maxVel / 2;
    
    double tDeccel = abs(maxVel) / config->aEnd;
    double posDeccel = tDeccel * maxVel / 2;
    
    double posConst = deltaPos - posAccel - posDeccel;
    double tConst = abs(posConst / maxVel);
    
    double iAccel = min(minsSinceStart, tAccel);
    double iConst = min(max(minsSinceStart - tAccel, 0), tConst);
    double iDeccel = min(max(minsSinceStart - tAccel - tConst, 0), tDeccel);
    
    double accelSeg = config->aStart / 2 * iAccel * iAccel;
    double constSeg = abs(maxVel) * iConst;
    double deccelSeg = -config->aEnd / 2 * iDeccel * iDeccel + abs(maxVel) * iDeccel;
    
    *secsToCompletion = (tAccel + tConst + tDeccel - minsSinceStart) * 60;
    if(minsSinceStart > tAccel + tConst + tDeccel) {
        *phase = 3;
        *targetVel = 0;
    }
    else if(iDeccel > 0) {
        *phase = 2;
        *targetVel = maxVel - sign(maxVel) * abs(config->aEnd * iDeccel);
    }
    else if(iConst > 0) {
        *phase = 1;
        *targetVel = maxVel;
    }
    else {
        *phase = 0;
        *targetVel = sign(maxVel) * abs(config->aStart * iAccel);
    }
    
    return startPos + sign(maxVel) * (accelSeg + constSeg + deccelSeg);
}
double calcFF(struct SlotConfig const * config, double error, double targetVel,double* fFactor, double* sFactor, double* vFactor) {
    const double sv = getSourceVoltage();
    
    *fFactor = sv == 0 ? 0 : config->kF / sv;
    
    /*
    From Phoenix 6 Slot0Configs.StaticFeedforwardSign:
    
    "The default behavior uses the velocity reference sign. This works well with velocity closed loop, Motion Magic® controls, and position closed loop when velocity reference is specified (motion profiling).

However, when using position closed loop with zero velocity reference (no motion profiling), the application may want to apply static feedforward based on the sign of closed loop error instead. When doing so, we recommend using the minimal amount of kS, otherwise the motor output may dither when closed loop error is near zero."
    */
    int sPolarity;
    switch(config->kSMode) {
        default:
        case KS_MODE_ERROR_BASED: {
            sPolarity = sign(error);
            break;
        }
        case KS_MODE_VELOCITY_BASED: {
            sPolarity = sign(targetVel);
            break;
        }
    }
    *sFactor = (sv == 0 ? 0 : config->kS / sv) * sPolarity;
    
    *vFactor = sv == 0 ? 0 : (config->kV * targetVel / sv);
    
    return *fFactor + *sFactor + *vFactor;
}
