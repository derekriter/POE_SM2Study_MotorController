#include "controlMode.hpp"
#include "hardware.hpp"
#include "util.hpp"
#include "serial.hpp"

#include <assert.h>

inline void DisabledControlMode::update(unsigned long deltaMicros, struct SlotConfig const * const slots) {
    dutyCycle(0);
}
inline const uint8_t DisabledControlMode::getID() const {return 255u;}
void DisabledControlMode::getControlModeData(ControlModeData* data) {
    *data = ControlModeData {};
    data->controlID = getID();
    data->dutyOut = 0;
    data->voltageOut = 0;
    
    data->hasTarget = false;
    data->hasError = false;
    data->hasPFactor = false;
    data->hasIFactor = false;
    data->hasDFactor = false;
    data->hasSFactor = false;
    data->hasSubError = false;
    data->hasSecsToCompletion = false;
    data->hasPhase = false;
}

inline void StopControlMode::update(unsigned long deltaMicros, struct SlotConfig const * const slots) {
    dutyCycle(0);
}
inline const uint8_t StopControlMode::getID() const {return 0u;}
void StopControlMode::getControlModeData(ControlModeData* data) {
    *data = ControlModeData {};
    data->controlID = getID();
    data->dutyOut = 0;
    data->voltageOut = 0;
    
    data->hasTarget = false;
    data->hasError = false;
    data->hasPFactor = false;
    data->hasIFactor = false;
    data->hasDFactor = false;
    data->hasSFactor = false;
    data->hasSubError = false;
    data->hasSecsToCompletion = false;
    data->hasPhase = false;
}

DutyCycleControlMode::DutyCycleControlMode(double dutyCycle) {
    _duty = min(max(dutyCycle, -1), 1);
}
inline void DutyCycleControlMode::update(unsigned long deltaMicros, struct SlotConfig const * const slots) {
    dutyCycle(_duty);
}
inline const uint8_t DutyCycleControlMode::getID() const {return 1u;}
void DutyCycleControlMode::getControlModeData(ControlModeData* data) {
    *data = ControlModeData {};
    data->controlID = getID();
    data->dutyOut = _duty;
    data->voltageOut = _duty * getSourceVoltage();
    
    data->hasTarget = false;
    data->hasError = false;
    data->hasPFactor = false;
    data->hasIFactor = false;
    data->hasDFactor = false;
    data->hasSFactor = false;
    data->hasSubError = false;
    data->hasSecsToCompletion = false;
    data->hasPhase = false;
}
bool DutyCycleControlMode::parseFromCommandArgs(char const * const commandArgs, DutyCycleControlMode** const controlOut) {
    double duty;
    char* arg2Start;
    if(!parseDouble(commandArgs, &duty, &arg2Start)) {
        const MessageFrameP msg =  {SEVERITY_ERROR, F("Malformed DutyCycleControlMode, failed to parse arg1 as a double")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    
    if(*arg2Start != '\0') {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed DutyCycleControlMode, too many arguments")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    
    if(abs(duty) > 1) {
        const MessageFrameP msg = {SEVERITY_WARNING, F("Control reference is beyond range for DutyCycleControlMode")};
        sendMessageFrameP(&msg);
    }
    *controlOut = new DutyCycleControlMode(duty);
    return true;
}

VoltageControlMode::VoltageControlMode(double voltage) {
    _voltage = voltage;
    _lastDuty = 0;
    _lastVS = 0;
}
void VoltageControlMode::update(unsigned long deltaMicros, struct SlotConfig const * const slots) {
    _lastVS = getSourceVoltage();
    _lastDuty = min(max(_lastVS == 0 ? 0 : _voltage / _lastVS, -1), 1);
    
    dutyCycle(_lastDuty);
}
inline const uint8_t VoltageControlMode::getID() const {return 2u;}
void VoltageControlMode::getControlModeData(ControlModeData* data) {
    *data = ControlModeData {};
    data->controlID = getID();
    data->dutyOut = _lastDuty;
    data->voltageOut = _lastDuty * _lastVS;
    
    data->hasTarget = false;
    data->hasError = false;
    data->hasPFactor = false;
    data->hasIFactor = false;
    data->hasDFactor = false;
    data->hasSFactor = false;
    data->hasSubError = false;
    data->hasSecsToCompletion = false;
    data->hasPhase = false;
}
bool VoltageControlMode::parseFromCommandArgs(char const * const commandArgs, VoltageControlMode** const controlOut) {
    double voltage;
    char* arg2Start;
    if(!parseDouble(commandArgs, &voltage, &arg2Start)) {
        const MessageFrameP msg =  {SEVERITY_ERROR, F("Malformed VoltageControlMode, failed to parse arg1 as a double")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    
    if(*arg2Start != '\0') {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed VoltageControlMode, too many arguments")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    
    *controlOut = new VoltageControlMode(voltage);
    return true;
}

PIDPositionControlMode::PIDPositionControlMode(double targetRots, uint8_t slot) {
    _target = targetRots;
    
    assert(slot < 6);
    _slot = slot;
    
    _lastDuty = 0;
    _lastVS = 0;
    _lastError = 0;
    _iAccum = 0;
    _totalP = 0;
    _totalI = 0;
    _totalD = 0;
    _totalS = 0;
    _updatesSinceLastFrame = 0;
}
void PIDPositionControlMode::update(unsigned long deltaMicros, struct SlotConfig const * const slots) {
    _lastVS = getSourceVoltage();
    
    SlotConfig const * config = slots + _slot;
    double p, i, d, s;
    
    _lastDuty = calcPIDS(getEncoderRotations(), _target, config, deltaMicros, &_lastError, &p, &i, &_iAccum, &d, &s);
    
    _totalP += p;
    _totalI += i;
    _totalD += d;
    _totalS += s;
    _updatesSinceLastFrame++;
    
    _lastDuty = min(max(_lastDuty, -1), 1);
    dutyCycle(_lastDuty);
}
inline const uint8_t PIDPositionControlMode::getID() const {return 3u;}
void PIDPositionControlMode::getControlModeData(ControlModeData* data) {
    *data = ControlModeData {};
    data->controlID = getID();
    data->dutyOut = _lastDuty;
    data->voltageOut = _lastDuty * _lastVS;
    
    data->hasTarget = true;
    data->target = _target;
    data->hasError = true;
    data->error = _lastError;
    data->hasPFactor = true;
    data->pFactor = _totalP / _updatesSinceLastFrame;
    data->hasIFactor = true;
    data->iFactor = _totalI / _updatesSinceLastFrame;
    data->hasDFactor = true;
    data->dFactor = _totalD / _updatesSinceLastFrame;
    data->hasSFactor = true;
    data->sFactor = _totalS / _updatesSinceLastFrame;
    data->hasSubError = false;
    data->hasSecsToCompletion = false;
    data->hasPhase = false;
    
    _updatesSinceLastFrame = 0;
    _totalP = 0;
    _totalI = 0;
    _totalD = 0;
    _totalS = 0;
}
bool PIDPositionControlMode::parseFromCommandArgs(char const * const commandArgs, PIDPositionControlMode** const controlOut) {
    double target;
    char* arg2Start;
    if(!parseDouble(commandArgs, &target, &arg2Start)) {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed PIDPositionControlMode, failed to parse arg1 as a double")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    
    if(*arg2Start == '\0') {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed PIDPositionControlMode, too few arguments")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    uint8_t slot;
    char* arg3Start;
    if(!parseUInt(arg2Start, &slot, &arg3Start)) {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed PIDPositionControlMode, failed to parse arg2 as uint8_t")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    if(slot >= 6) {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed PIDPositionControlMode, slot must be in range [0, 5]")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    
    if(*arg3Start != '\0') {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed PIDPositionControlMode, too many arguments")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    
    *controlOut = new PIDPositionControlMode(target, slot);
    return true;
}

PIDVelocityControlMode::PIDVelocityControlMode(double targetRPM, uint8_t slot) {
    _target = targetRPM;
    
    assert(slot < 6);
    _slot = slot;
    
    _lastDuty = 0;
    _lastVS = 0;
    _lastError = 0;
    _iAccum = 0;
    _totalP = 0;
    _totalI = 0;
    _totalD = 0;
    _totalS = 0;
    _updatesSinceLastFrame = 0;
}
void PIDVelocityControlMode::update(unsigned long deltaMicros, struct SlotConfig const * const slots) {
    _lastVS = getSourceVoltage();
    
    SlotConfig const * config = slots + _slot;
    double p, i, d, s;
    
    _lastDuty = calcPIDS(getEncoderRPM(), _target, config, deltaMicros, &_lastError, &p, &i, &_iAccum, &d, &s);
    
    _totalP += p;
    _totalI += i;
    _totalD += d;
    _totalS += s;
    _updatesSinceLastFrame++;
    _lastDuty = min(max(_lastDuty, -1), 1);
    
    dutyCycle(_lastDuty);
}
inline const uint8_t PIDVelocityControlMode::getID() const {return 4u;}
void PIDVelocityControlMode::getControlModeData(ControlModeData* data) {
    *data = ControlModeData {};
    data->controlID = getID();
    data->dutyOut = _lastDuty;
    data->voltageOut = _lastDuty * _lastVS;
    
    data->hasTarget = true;
    data->target = _target;
    data->hasError = true;
    data->error = _lastError;
    data->hasPFactor = true;
    data->pFactor = _totalP / _updatesSinceLastFrame;
    data->hasIFactor = true;
    data->iFactor = _totalI / _updatesSinceLastFrame;
    data->hasDFactor = true;
    data->dFactor = _totalD / _updatesSinceLastFrame;
    data->hasSFactor = true;
    data->sFactor = _totalS / _updatesSinceLastFrame;
    data->hasSubError = false;
    data->hasSecsToCompletion = false;
    data->hasPhase = false;
    
    _updatesSinceLastFrame = 0;
    _totalP = 0;
    _totalI = 0;
    _totalD = 0;
    _totalS = 0;
}
bool PIDVelocityControlMode::parseFromCommandArgs(char const * const commandArgs, PIDVelocityControlMode** const controlOut) {
    double target;
    char* arg2Start;
    if(!parseDouble(commandArgs, &target, &arg2Start)) {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed PIDVelocityControlMode, failed to parse arg1 as a double")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    
    if(*arg2Start == '\0') {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed PIDVelocityControlMode, too few arguments")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    uint8_t slot;
    char* arg3Start;
    if(!parseUInt(arg2Start, &slot, &arg3Start)) {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed PIDVelocityControlMode, failed to parse arg2 as uint8_t")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    if(slot >= 6) {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed PIDVelocityControlMode, slot must be in range [0, 5]")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    
    if(*arg3Start != '\0') {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed PIDVelocityControlMode, too many arguments")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    
    *controlOut = new PIDVelocityControlMode(target, slot);
    return true;
}

TrapezoidalPIDPositionControlMode::TrapezoidalPIDPositionControlMode(double targetRots, uint8_t slot) {
    _target = targetRots;
    
    assert(slot < 6);
    _slot = slot;
    
    _lastDuty = 0;
    _lastVS = 0;
    _lastMajorError = 0;
    _lastMinorError = 0;
    _iAccum = 0;
    _microsSinceStart = 0;
    _updatesSinceLastFrame = 0;
    _totalP = 0;
    _totalI = 0;
    _totalD = 0;
    _totalS = 0;
    _startRots = NAN;
    _lastPhase = 0;
    _lastSecsToCompletion = 0;
}
void TrapezoidalPIDPositionControlMode::update(unsigned long deltaMicros, struct SlotConfig const * const slots) {
    _microsSinceStart += deltaMicros;
    _lastVS = getSourceVoltage();
    
    if(isnan(_startRots)) {
        _startRots = getEncoderRotations();
    }
    
    SlotConfig const * config = slots + _slot;
    double currentTarget = calcTrapProfile(_microsSinceStart, _startRots, _target, config, &_lastSecsToCompletion, &_lastPhase);
    
    double currentPosition = getEncoderRotations();
    _lastMajorError = _target - currentPosition;
    
    double p, i, d, s;
    _lastDuty = calcPIDS(currentPosition, currentTarget, config, deltaMicros, &_lastMinorError, &p, &i, &_iAccum, &d, &s);
    
    _totalP += p;
    _totalI += i;
    _totalD += d;
    _totalS += s;
    _updatesSinceLastFrame++;
    
    _lastDuty = min(max(_lastDuty, -1), 1);
    dutyCycle(_lastDuty);
}
uint8_t const TrapezoidalPIDPositionControlMode::getID() const {return 5u;}
void TrapezoidalPIDPositionControlMode::getControlModeData(struct ControlModeData* data) {
    *data = ControlModeData {};
    data->controlID = getID();
    data->dutyOut = _lastDuty;
    data->voltageOut = _lastDuty * _lastVS;
    
    data->hasTarget = true;
    data->target = _target;
    data->hasError = true;
    data->error = _lastMajorError;
    data->hasPFactor = true;
    data->pFactor = _totalP / _updatesSinceLastFrame;
    data->hasIFactor = true;
    data->iFactor = _totalI / _updatesSinceLastFrame;
    data->hasDFactor = true;
    data->dFactor = _totalD / _updatesSinceLastFrame;
    data->hasSFactor = true;
    data->sFactor = _totalS / _updatesSinceLastFrame;
    data->hasSubError = true;
    data->subError = _lastMinorError;
    data->hasSecsToCompletion = true;
    data->secsToCompletion = _lastSecsToCompletion;
    data->hasPhase = true;
    data->phase = _lastPhase;
    
    _updatesSinceLastFrame = 0;
    _totalP = 0;
    _totalI = 0;
    _totalD = 0;
    _totalS = 0;
}
bool TrapezoidalPIDPositionControlMode::parseFromCommandArgs(char const * const commandArgs, TrapezoidalPIDPositionControlMode** const controlOut) {
    double target;
    char* arg2Start;
    if(!parseDouble(commandArgs, &target, &arg2Start)) {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed TrapezoidalPIDPositionControlMode, failed to parse arg1 as a double")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    
    if(*arg2Start == '\0') {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed TrapezoidalPIDPositionControlMode, too few arguments")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    uint8_t slot;
    char* arg3Start;
    if(!parseUInt(arg2Start, &slot, &arg3Start)) {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed TrapezoidalPIDPositionControlMode, failed to parse arg2 as uint8_t")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    if(slot >= 6) {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed TrapezoidalPIDPositionControlMode, slot must be in range [0, 5]")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    
    if(*arg3Start != '\0') {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed TrapezoidalPIDPositionControlMode, too many arguments")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    
    *controlOut = new TrapezoidalPIDPositionControlMode(target, slot);
    return true;
}
