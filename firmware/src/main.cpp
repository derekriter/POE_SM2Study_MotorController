#include <Arduino.h>
#include "serial.hpp"
#include "control.hpp"

void setup() {
    setupPins();
    
    setMotorEnabled(false);
    stop();
    setControlMode(CONTROL_MODE_NONE);
    setControlReference(0);
    
    Serial.begin(115200);
    Serial.setTimeout(10); //make sure that receiving data doesn't get in the way of controlling the motor
}

void loop() {
    static unsigned long lastDataTime = 0;
    static double sumTPSSinceLastData = 0;
    static float sumPIDErrSinceLastData = 0;
    static unsigned int framesSinceLastData = 0;
    
    //update velocity reference. Velocity measurement will break if this is removed
    updateVelocity();
    sumTPSSinceLastData += getEncoderTicksPerSecond();
    framesSinceLastData++;
    
    switch(getControlMode()) {
        default:
        case CONTROL_MODE_NONE: {
            stop();
            break;
        }
        case CONTROL_MODE_DUTY_CYCLE: {
            driveDutyCycle(getControlReference());
            break;
        }
        case CONTROL_MODE_VOLTAGE: {
            driveVoltage(getControlReference());
            break;
        }
        case CONTROL_MODE_PID_POSITION: {
            drivePIDToPosition(getControlReference());
            break;
        }
        case CONTROL_MODE_PID_VELOCITY: {
            drivePIDToVelocity(getControlReference());
            break;
        }
        case CONTROL_MODE_TRAP_POSITION: {
            driveProfileToPosition(getControlReference());
            break;
        }
    }
    
    sumPIDErrSinceLastData += getMostRecentPIDError();
    
    unsigned long currentTime = micros();
    if(currentTime - lastDataTime >= 1e6 / 40.0) {
        sendDataFrame(
            sumTPSSinceLastData / framesSinceLastData,
            sumPIDErrSinceLastData / framesSinceLastData
        );
        
        lastDataTime = currentTime;
        sumTPSSinceLastData = 0;
        sumPIDErrSinceLastData = 0;
        framesSinceLastData = 0;
    }
    
    String incoming;
    if(getIncomingIfAvailable(&incoming)) {
        processCommand(&incoming);
    }
}
