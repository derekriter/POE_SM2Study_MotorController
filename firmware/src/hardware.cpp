#include "hardware.hpp"

bool _motorEnabled = false;
volatile long _encoderPosition = 0;
double _velocityTPS = 0;

void initHardware() {
    pinMode(PIN_MOTOR_FORWARD, OUTPUT);
    pinMode(PIN_MOTOR_REVERSE, OUTPUT);
    pinMode(PIN_MOTOR_ENABLE, OUTPUT);
    pinMode(PIN_SOURCE_VOLTAGE, INPUT);
    pinMode(PIN_ENCODER_A, INPUT_PULLUP);
    pinMode(PIN_ENCODER_B, INPUT_PULLUP);
    
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
double getSourceVoltage() {
    const int R1 = 969; //r1 value in the voltage divider ; 1000 ohm resistor with 5% tolerance, measured with multimeter
    const int R2 = 542; //r2 value in the voltage divider ; 560 ohm resistor with 5% tolerance, measured with multimeter
    const float REF_VOLTAGE = 4.24; //should be 5 V but the voltage regulator is pretty shit
    
    float percent = analogRead(PIN_SOURCE_VOLTAGE) / 1023.0;
    //V_in = (V_s * R2) / (R1 + R2)
    //perc = V_in / V_r
    //therefore:
    //V_s = perc * V_r * (R1 + R2) / R2
    return percent * REF_VOLTAGE * (R1 + R2) / R2;
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
