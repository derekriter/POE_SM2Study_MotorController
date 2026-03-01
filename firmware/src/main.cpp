#include <Arduino.h>
#include "serial.hpp"
#include "control.hpp"
#include "controlMode.hpp"

void setup() {
    setupPins();
    
    setMotorEnabled(false);
    setControlMode(StopControlMode());
    
    Serial.begin(115200);
    Serial.setTimeout(10); //make sure that receiving data doesn't get in the way of controlling the motor
}

void loop() {
    static unsigned long lastMicros = 0;
    static unsigned long lastDataTime = 0;
    static double sumTPSSinceLastData = 0;
    static float sumPIDErrSinceLastData = 0;
    static unsigned int framesSinceLastData = 0;
    
    unsigned long currentTime = micros();
    
    //update velocity reference. Velocity measurement will break if this is removed
    updateVelocity();
    sumTPSSinceLastData += getEncoderTicksPerSecond();
    framesSinceLastData++;
    
    getControlMode()->update(currentTime - lastMicros);
    
    sumPIDErrSinceLastData += getMostRecentPIDError();
    
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
    
    lastMicros = currentTime;
}
