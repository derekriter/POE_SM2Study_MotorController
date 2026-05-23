#include "hardware.hpp"

bool _motorEnabled = false;
volatile long _encoderPosition = 0;
double _velocityTPS = 0;
double _sourceVolts = 0;

void initHardware() {
    pinMode(PIN_MOTOR_FORWARD, OUTPUT);
    pinMode(PIN_MOTOR_REVERSE, OUTPUT);
    pinMode(PIN_MOTOR_ENABLE, OUTPUT);
    pinMode(PIN_ENCODER_A, INPUT_PULLUP);
    pinMode(PIN_ENCODER_B, INPUT_PULLUP);
    
    #if USE_EXTERNAL_AREF
    analogReference(EXTERNAL);
    #endif
    pinMode(PIN_SOURCE_VOLTAGE, INPUT);
    
    attachInterrupt(digitalPinToInterrupt(PIN_ENCODER_A), _encoderISR, CHANGE);
    attachInterrupt(digitalPinToInterrupt(PIN_ENCODER_B), _encoderISR, CHANGE);
    
    setMotorEnabled(false);
    dutyCycle(0);
}

void setMotorEnabled(bool enabled) {
    digitalWrite(PIN_MOTOR_ENABLE, enabled);
    _motorEnabled = enabled;
}
bool getMotorEnabled() {
    return _motorEnabled;
}
void dutyCycle(double dutyCycle) {
    dutyCycle = min(max(dutyCycle, -1), 1);
    
    if(dutyCycle == 0) {
        digitalWrite(PIN_MOTOR_FORWARD, 0);
        digitalWrite(PIN_MOTOR_REVERSE, 0);
    }
    else if(dutyCycle > 0) {
        analogWrite(PIN_MOTOR_FORWARD, (int) (dutyCycle * 255));
        digitalWrite(PIN_MOTOR_REVERSE, 0);
    }
    else {
        digitalWrite(PIN_MOTOR_FORWARD, 0);
        analogWrite(PIN_MOTOR_REVERSE, (int) (-dutyCycle * 255));
    }
}
void updateSourceVoltage() {
    double Vin = 0;
    for(int i = 0; i < SV_SAMPLE_COUNT; i++) {
        //For extra accuraccy, add 0.5 and divide by 1024: https://skillbank.co.uk/arduino/adc.htm
        Vin += (analogRead(PIN_SOURCE_VOLTAGE) + 0.5) * VREF / 1024.0;
    }
    Vin /= SV_SAMPLE_COUNT;
    
    _sourceVolts =  Vin * (SV_R1 + SV_R2) / SV_R2;
}
double getSourceVoltage() {
    return _sourceVolts;
}

//https://forum.arduino.cc/t/this-is-how-i-use-an-optical-encoder/1034970
void _encoderISR() {
    static byte lastPortD = _ENCODER_SIGNAL_A;
    
    //https://docs.arduino.cc/retired/hacking/software/PortManipulation/
    byte portD = PIND & _ENCODER_SIGNAL_AB;
    byte delta = lastPortD ^ portD;
    
    if(delta & _ENCODER_SIGNAL_A) {
        _encoderPosition++;
    }
    if(delta & _ENCODER_SIGNAL_B) {
        _encoderPosition--;
    }
    if(portD && portD != _ENCODER_SIGNAL_AB) {
        portD ^= _ENCODER_SIGNAL_AB;
    }
    
    lastPortD = portD;
}
void updateVelocity() {
    static unsigned long lastMicros = 0;
    static long lastEncoderPos = 0;
    
    unsigned long currentMicros = micros();
    long encoderPos = getEncoderTicks();
    
    _velocityTPS = (double) (encoderPos - lastEncoderPos) / (currentMicros - lastMicros) * 1e6;
    
    lastMicros = currentMicros;
    lastEncoderPos = encoderPos;
}
long getEncoderTicks() {
    noInterrupts();
    #if INVERT_ENCODER
    long pos = -_encoderPosition;
    #else
    long pos = _encoderPosition;
    #endif
    interrupts();
    return pos;
}
double getEncoderRotations() {
    return (double) getEncoderTicks() / ENCODER_TICKS_PER_ROTATION;
}
double getEncoderTicksPerSecond() {
    return _velocityTPS;
}
double getEncoderRPM() {
    return getEncoderTicksPerSecond() / ENCODER_TICKS_PER_ROTATION * 60;
}
