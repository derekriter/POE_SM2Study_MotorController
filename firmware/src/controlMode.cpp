#include "controlMode.hpp"
#include "hardware.hpp"
#include "util.hpp"
#include "serial.hpp"

void DisabledControlMode::update(unsigned long deltaMicros) {
    dutyCycle(0);
}
uint8_t DisabledControlMode::getID() {return 255u;}
char* DisabledControlMode::getControlModeData() {
    char* data = (char*) malloc(4);
    itoa(getID(), data, 10);
    
    return data;
}

void StopControlMode::update(unsigned long deltaMicros) {
    dutyCycle(0);
}
uint8_t StopControlMode::getID() {return 0u;}
char* StopControlMode::getControlModeData() {
    char* data = (char*) malloc(4);
    itoa(getID(), data, 10);
    
    return data;
}

DutyCycleControlMode::DutyCycleControlMode(double dutyCycle) {
    _duty = dutyCycle;
}
void DutyCycleControlMode::update(unsigned long deltaMicros) {
    dutyCycle(_duty);
}
uint8_t DutyCycleControlMode::getID() {return 1u;}
char* DutyCycleControlMode::getControlModeData() {
    char dutyOut[8];
    dtostrf(_duty, 1, 4, dutyOut);
    
    const size_t len = 13 + 3 + 7 + 1;
    char* data = (char*) malloc(len);
    snprintf(data, len, "{\"id\":%u,\"do\":%s}", getID(), dutyOut);
    
    return data;
}
bool DutyCycleControlMode::parseFromCommandArgs(const char* commandArgs, DutyCycleControlMode** controlOut) {
    double duty;
    char* arg2Start;
    if(!parseDouble(commandArgs, &duty, &arg2Start)) {
        MessageFrame msg =  {SEVERITY_ERROR, "Malformed DutyCycleControlMode, failed to parse arg1 as a double"};
        sendMessageFrame(&msg);
        
        return false;
    }
    
    if(*arg2Start != '\0') {
        MessageFrame msg = {SEVERITY_ERROR, "Malformed DutyCycleControlMode, too many arguments"};
        sendMessageFrame(&msg);
        
        return false;
    }
    
    if(abs(duty) > 1) {
        MessageFrame msg = {SEVERITY_WARNING, "Control reference is beyond range for DutyCycleControlMode"};
        sendMessageFrame(&msg);
    }
    *controlOut = new DutyCycleControlMode(duty);
    return true;
}

VoltageControlMode::VoltageControlMode(double voltage) {
    _voltage = voltage;
    _lastDuty = 0;
}
void VoltageControlMode::update(unsigned long deltaMicros) {
    double source = getSourceVoltage();
    double out = min(max(source == 0 ? 0 : _voltage / source, -1), 1);
    
    dutyCycle(out);
    _lastDuty = out;
}
uint8_t VoltageControlMode::getID() {return 2u;}
char* VoltageControlMode::getControlModeData() {
    char dutyOut[8];
    dtostrf(_lastDuty, 1, 4, dutyOut);
    
    char voltsOut[10];
    dtostrf(_lastDuty * getSourceVoltage(), 1, 4, voltsOut);
    
    const size_t len = 19 + 3 + 7 + 9 + 1;
    char* data = (char*) malloc(len);
    snprintf(data, len, "{\"id\":%u,\"do\":%s,\"vo\":%s}", getID(), dutyOut, voltsOut);
    
    return data;
}
bool VoltageControlMode::parseFromCommandArgs(const char* commandArgs, VoltageControlMode** controlOut) {
    double voltage;
    char* arg2Start;
    if(!parseDouble(commandArgs, &voltage, &arg2Start)) {
        MessageFrame msg =  {SEVERITY_ERROR, "Malformed VoltageControlMode, failed to parse arg1 as a double"};
        sendMessageFrame(&msg);
        
        return false;
    }
    
    if(*arg2Start != '\0') {
        MessageFrame msg = {SEVERITY_ERROR, "Malformed VoltageControlMode, too many arguments"};
        sendMessageFrame(&msg);
        
        return false;
    }
    
    *controlOut = new VoltageControlMode(voltage);
    return true;
}
