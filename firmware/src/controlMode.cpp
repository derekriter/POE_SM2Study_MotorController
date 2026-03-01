#include "controlMode.hpp"
#include "control.hpp"
#include "serial.hpp"
#include "util.hpp"

StopControlMode::StopControlMode() {}
void StopControlMode::update(unsigned long deltaMicros) {
    driveDutyCycle(0);
}
uint8_t StopControlMode::getID() {return 0;}
bool StopControlMode::parseFromCommandArgs(const char* commandArgs, StopControlMode* controlOut) {
    if(*commandArgs != '\0') {
        sendBadFrame("Malformed StopControlMode, too many arguments", SEVERITY_ERROR);
        return false;
    }
    
    *controlOut = StopControlMode();
    return true;
}


DutyCycleControlMode::DutyCycleControlMode(double dutyCycle) {
    duty = dutyCycle;
}
void DutyCycleControlMode::update(unsigned long deltaMicros) {
    driveDutyCycle(duty);
}
uint8_t DutyCycleControlMode::getID() {return 1;}
bool DutyCycleControlMode::parseFromCommandArgs(const char* commandArgs, DutyCycleControlMode* controlOut) {
    double duty;
    char* arg2Start;
    if(!parseDouble(commandArgs, &duty, &arg2Start)) {
        sendBadFrame("Malformed DutyCycleControlMode, failed to parse arg1 as a double", SEVERITY_ERROR);
        return false;
    }
    if(abs(duty) > 1) {
        sendBadFrame("Control reference is beyond range for DutyCycleControlMode", SEVERITY_WARNING);
    }
    
    if(*arg2Start != '\0') {
        sendBadFrame("Malformed DutyCycleControlMode, too many arguments", SEVERITY_ERROR);
        return false;
    }
    
    *controlOut = DutyCycleControlMode(duty);
    return true;
}
