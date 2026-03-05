#include "controlMode.hpp"
#include "hardware.hpp"
#include "util.hpp"
#include "serial.hpp"

inline void DisabledControlMode::update(unsigned long deltaMicros, const struct SlotConfig* slots) {
    dutyCycle(0);
}
inline const uint8_t DisabledControlMode::getID() const {return 255u;}
char* DisabledControlMode::getControlModeData() const {
    char* data = static_cast<char*>(malloc(4));
    itoa(getID(), data, 10);
    
    return data;
}

inline void StopControlMode::update(unsigned long deltaMicros, const struct SlotConfig* slots) {
    dutyCycle(0);
}
inline const uint8_t StopControlMode::getID() const {return 0u;}
char* StopControlMode::getControlModeData() const {
    char* data = static_cast<char*>(malloc(4));
    itoa(getID(), data, 10);
    
    return data;
}

DutyCycleControlMode::DutyCycleControlMode(double dutyCycle) {
    _duty = dutyCycle;
}
inline void DutyCycleControlMode::update(unsigned long deltaMicros, const struct SlotConfig* slots) {
    dutyCycle(_duty);
}
inline const uint8_t DutyCycleControlMode::getID() const {return 1u;}
char* DutyCycleControlMode::getControlModeData() const {
    char dutyOut[8];
    dtostrf(_duty, 1, 4, dutyOut);
    
    const size_t len = 13 + 3 + 7 + 1;
    char* data = static_cast<char*>(malloc(len));
    snprintf_P(data, len, (char const *) F("{\"id\":%u,\"do\":%s}"), getID(), dutyOut);
    
    return data;
}
bool DutyCycleControlMode::parseFromCommandArgs(const char* commandArgs, DutyCycleControlMode** controlOut) {
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
}
void VoltageControlMode::update(unsigned long deltaMicros, const struct SlotConfig* slots) {
    double source = getSourceVoltage();
    double out = min(max(source == 0 ? 0 : _voltage / source, -1), 1);
    
    dutyCycle(out);
    _lastDuty = out;
}
inline const uint8_t VoltageControlMode::getID() const {return 2u;}
char* VoltageControlMode::getControlModeData() const {
    char dutyOut[8];
    dtostrf(_lastDuty, 1, 4, dutyOut);
    
    char voltsOut[10];
    dtostrf(_lastDuty * getSourceVoltage(), 1, 4, voltsOut);
    
    const size_t len = 19 + 3 + 7 + 9 + 1;
    char* data = static_cast<char*>(malloc(len));
    snprintf_P(data, len, (const char*) F("{\"id\":%u,\"do\":%s,\"vo\":%s}"), getID(), dutyOut, voltsOut);
    
    return data;
}
bool VoltageControlMode::parseFromCommandArgs(const char* commandArgs, VoltageControlMode** controlOut) {
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
