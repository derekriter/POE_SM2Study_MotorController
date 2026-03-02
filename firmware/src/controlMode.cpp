#include "controlMode.hpp"
#include "hardware.hpp"
#include "util.hpp"
#include "serial.hpp"

void StopControlMode::update(unsigned long deltaMicros) {
    dutyCycle(0);
}
uint8_t StopControlMode::getID() {return 0u;}
bool StopControlMode::parseFromCommandArgs(const char* commandArgs, StopControlMode** controlOut) {
    if(*commandArgs != '\0') {
        MessageFrame msg = {SEVERITY_ERROR, "Malformed StopControlMode, too many arguments"};
        sendMessageFrame(&msg);
        
        return false;
    }
    
    *controlOut = new StopControlMode();
    return true;
}


DutyCycleControlMode::DutyCycleControlMode(double dutyCycle) {
    _duty = dutyCycle;
}
void DutyCycleControlMode::update(unsigned long deltaMicros) {
    dutyCycle(_duty);
}
uint8_t DutyCycleControlMode::getID() {return 1u;}
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
