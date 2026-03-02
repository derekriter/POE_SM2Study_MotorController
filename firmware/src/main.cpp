#include <Arduino.h>
#include "serial.hpp"
#include "hardware.hpp"
#include "controlMode.hpp"

ControlMode* _controlMode;
ControlMode* _disabledControlMode;

void setup() {
    initHardware();
    
    Serial.begin(115200);
    Serial.setTimeout(10); //make sure that receiving data doesn't get in the way of controlling the motor
    
    _controlMode = new StopControlMode();
    _disabledControlMode = new DisabledControlMode();
}

void loop() {
    static unsigned long lastMicros = 0;
    static unsigned long lastDataTime = 0;
    static double sumRPMSinceLastData = 0;
    static unsigned int framesSinceLastData = 0;
    
    unsigned long currentMicros = micros();
    
    //update velocity reference. Velocity measurement will break if this is removed
    updateVelocity();
    sumRPMSinceLastData += getEncoderRPM();
    framesSinceLastData++;
    
    //enforce always having a control mode
    if(_controlMode == nullptr) {
        _controlMode = new StopControlMode();
    }
    //only run the commanded mode if the motor is enabled
    if(getMotorEnabled()) {
        _controlMode->update(currentMicros - lastMicros);
    }
    else {
        _disabledControlMode->update(currentMicros - lastMicros);
    }
    
    if(currentMicros - lastDataTime >= 1e6 / 40.0) {
        char* cm;
        if(getMotorEnabled()) {
            cm = _controlMode->getControlModeData();
        }
        else {
            cm = _disabledControlMode->getControlModeData();
        }
        
        DataFrame data;
        data.enabled = getMotorEnabled();
        data.sourceVoltage = getSourceVoltage();
        data.position = getEncoderRotations();
        data.velocity = sumRPMSinceLastData / framesSinceLastData;
        data.controlModeData = cm;
        
        sendDataFrame(&data);
        free(cm);
        
        lastDataTime = currentMicros;
        sumRPMSinceLastData = 0;
        framesSinceLastData = 0;
    }
    
    String incoming;
    if(getIncomingIfAvailable(&incoming)) {
        ReceivedCommand todo;
        if(processCommand(&incoming, &todo)) {
            if(todo.changeControlMode != nullptr) {
                if(_controlMode != nullptr) delete _controlMode;
                
                _controlMode = todo.changeControlMode;
            }
            if(todo.changeEnabled == SET_DISABLE) {
                setMotorEnabled(false);
            }
            if(todo.changeEnabled == SET_ENABLE) {
                setMotorEnabled(true);
            }
        }
    }
    
    lastMicros = currentMicros;
}
