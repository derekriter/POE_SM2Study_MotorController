#include <Arduino.h>
#include "serial.hpp"
#include "hardware.hpp"
#include "controlMode.hpp"

ControlMode* _controlMode;
ControlMode* _disabledControlMode;
SlotConfig _slotConfigs[6];

void setup() {
    initHardware();
    
    Serial.begin(115200);
    Serial.setTimeout(10); //make sure that receiving data doesn't get in the way of controlling the motor
    
    _controlMode = new StopControlMode();
    _disabledControlMode = new DisabledControlMode();
    for(int i = 0; i < 6; i++) {
        _slotConfigs[i] = SlotConfig {0, 0, 0, 0, KS_MODE_ERROR_BASED, 0, 0, 0};
    }
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
        _controlMode->update(currentMicros - lastMicros, _slotConfigs);
    }
    else {
        _disabledControlMode->update(currentMicros - lastMicros, _slotConfigs);
    }
    
    if(currentMicros - lastDataTime >= 1e6 / 40.0) {
        ControlModeData cm;
        if(getMotorEnabled()) {
            _controlMode->getControlModeData(&cm);
        }
        else {
            _disabledControlMode->getControlModeData(&cm);
        }
        
        DataFrame data;
        data.enabled = getMotorEnabled();
        data.sourceVoltage = getSourceVoltage();
        data.position = getEncoderRotations();
        data.velocity = sumRPMSinceLastData / framesSinceLastData;
        data.controlModeData = &cm;
        data.millis = millis();
        
        sendDataFrame(&data);
        
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
            if(todo.changeSlotConfig != nullptr && todo.changeSlotNum < 6) {
                _slotConfigs[todo.changeSlotNum].kP = todo.changeSlotConfig->kP;
                _slotConfigs[todo.changeSlotNum].kI = todo.changeSlotConfig->kI;
                _slotConfigs[todo.changeSlotNum].kD = todo.changeSlotConfig->kD;
                _slotConfigs[todo.changeSlotNum].kS = todo.changeSlotConfig->kS;
                _slotConfigs[todo.changeSlotNum].kSMode = todo.changeSlotConfig->kSMode;
                _slotConfigs[todo.changeSlotNum].vMax = todo.changeSlotConfig->vMax;
                _slotConfigs[todo.changeSlotNum].aStart = todo.changeSlotConfig->aStart;
                _slotConfigs[todo.changeSlotNum].aEnd = todo.changeSlotConfig->aEnd;
                
                delete todo.changeSlotConfig;
            }
            if(todo.changeEnabled == SET_DISABLE) {
                setMotorEnabled(false);
            }
            if(todo.changeEnabled == SET_ENABLE) {
                setMotorEnabled(true);
            }
            if(todo.getSlotNum != NO_CHANGE && todo.getSlotNum < 6) {
                SlotFrame frame = {
                    todo.getSlotNum,
                    _slotConfigs[todo.getSlotNum].kP,
                    _slotConfigs[todo.getSlotNum].kI,
                    _slotConfigs[todo.getSlotNum].kD,
                    _slotConfigs[todo.getSlotNum].kS,
                    _slotConfigs[todo.getSlotNum].kSMode,
                    _slotConfigs[todo.getSlotNum].vMax,
                    _slotConfigs[todo.getSlotNum].aStart,
                    _slotConfigs[todo.getSlotNum].aEnd,
                };
                sendSlotFrame(&frame);
            }
        }
    }
    
    lastMicros = currentMicros;
}
