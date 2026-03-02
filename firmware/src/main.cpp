#include <Arduino.h>
#include "serial.hpp"
#include "hardware.hpp"
#include "controlMode.hpp"

ControlMode* _controlMode = new StopControlMode();

void setup() {
    initHardware();
    
    Serial.begin(115200);
    Serial.setTimeout(10); //make sure that receiving data doesn't get in the way of controlling the motor
}

void loop() {
    static unsigned long lastMicros = 0;
    static unsigned long lastDataTime = 0;
    static double sumRPMSinceLastData = 0;
    static float sumPIDErrSinceLastData = 0;
    static unsigned int framesSinceLastData = 0;
    
    unsigned long currentMicros = micros();
    
    //update velocity reference. Velocity measurement will break if this is removed
    updateVelocity();
    sumRPMSinceLastData += getEncoderRPM();
    
    //enforce always having a control mode
    if(_controlMode == nullptr) {
        _controlMode = new StopControlMode();
    }
    _controlMode->update(currentMicros - lastMicros);
    
    // sumPIDErrSinceLastData += getMostRecentPIDError();
    framesSinceLastData++;
    
    if(currentMicros - lastDataTime >= 1e6 / 40.0) {
        char* controlModeData = (char*) malloc(4);
        snprintf(controlModeData, 4, "%d", _controlMode->getID());
        
        DataFrame data = {
            getMotorEnabled(),
            getSourceVoltage(),
            controlModeData,
            sumRPMSinceLastData / framesSinceLastData,
            getEncoderRPM(),
            getCommandedOutput()
        };
        
        sendDataFrame(&data);
        free(controlModeData);
        
        lastDataTime = currentMicros;
        sumRPMSinceLastData = 0;
        sumPIDErrSinceLastData = 0;
        framesSinceLastData = 0;
    }
    
    String incoming;
    if(getIncomingIfAvailable(&incoming)) {
        ReceivedCommand todo;
        processCommand(&incoming, &todo);
        
        if(todo.changeEnabled == SET_DISABLE) {
            setMotorEnabled(false);
        }
        if(todo.changeControlMode != nullptr) {
            if(_controlMode != nullptr) delete _controlMode;
            
            _controlMode = todo.changeControlMode;
        }
        if(todo.changeEnabled == SET_ENABLE) {
            setMotorEnabled(true);
        }
    }
    
    lastMicros = currentMicros;
}
