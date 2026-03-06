#include "controlMode.hpp"
#include "hardware.hpp"
#include "util.hpp"
#include "serial.hpp"

#include <assert.h>

inline void DisabledControlMode::update(unsigned long deltaMicros, struct SlotConfig const * const slots) {
    dutyCycle(0);
}
inline const uint8_t DisabledControlMode::getID() const {return 255u;}
void DisabledControlMode::getControlModeData(ControlModeData* data) const {
    *data = ControlModeData {};
    data->controlID = getID();
    data->dutyOut = 0;
    data->voltageOut = 0;
    
    data->hasTarget = false;
    data->hasError = false;
}

inline void StopControlMode::update(unsigned long deltaMicros, struct SlotConfig const * const slots) {
    dutyCycle(0);
}
inline const uint8_t StopControlMode::getID() const {return 0u;}
void StopControlMode::getControlModeData(ControlModeData* data) const {
    *data = ControlModeData {};
    data->controlID = getID();
    data->dutyOut = 0;
    data->voltageOut = 0;
    
    data->hasTarget = false;
    data->hasError = false;
}

DutyCycleControlMode::DutyCycleControlMode(double dutyCycle) {
    _duty = min(max(dutyCycle, -1), 1);
}
inline void DutyCycleControlMode::update(unsigned long deltaMicros, struct SlotConfig const * const slots) {
    dutyCycle(_duty);
}
inline const uint8_t DutyCycleControlMode::getID() const {return 1u;}
void DutyCycleControlMode::getControlModeData(ControlModeData* data) const {
    *data = ControlModeData {};
    data->controlID = getID();
    data->dutyOut = _duty;
    data->voltageOut = _duty * getSourceVoltage();
    
    data->hasTarget = false;
    data->hasError = false;
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
void VoltageControlMode::getControlModeData(ControlModeData* data) const {
    *data = ControlModeData {};
    data->controlID = getID();
    data->dutyOut = _lastDuty;
    data->voltageOut = _lastDuty * _lastVS;
    
    data->hasTarget = false;
    data->hasError = false;
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
}
void PIDPositionControlMode::update(unsigned long deltaMicros, struct SlotConfig const * const slots) {
    _lastVS = getSourceVoltage();
    
    SlotConfig const * config = slots + _slot;
    
    _lastDuty = -0.4;
    _lastError = 10;
    dutyCycle(_lastDuty);
}
inline const uint8_t PIDPositionControlMode::getID() const {return 3u;}
void PIDPositionControlMode::getControlModeData(ControlModeData* data) const {
    *data = ControlModeData {};
    data->controlID = getID();
    data->dutyOut = _lastDuty;
    data->voltageOut = _lastDuty * _lastVS;
    
    data->hasTarget = true;
    data->target = _target;
    data->hasError = true;
    data->error = _lastError;
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
