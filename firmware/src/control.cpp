#include "control.hpp"
#include "util.hpp"
#include "serial.hpp"

bool _motorEnabled = false;
ControlMode _controlMode = StopControlMode();
float _commandedOutput = 0;

volatile long _encoderPosition = 0;
double _velocityTPS = 0;

float _iAccumlated = 0;
float _lastPIDError = 0;
float _kP = 0;
float _kI = 0;
float _kD = 0;
float _kS = 0;
unsigned long _lastPIDMicros = 0;
bool _resetPIDMicrosFlag = true;

float _vMax = 0;
float _aStart = 0;
float _aEnd = 0;
unsigned long _profileStartMicros = 0;
float _profileStartTicks = NAN;

void setupPins() {
    pinMode(PIN_MOTOR_FORWARD, OUTPUT);
    pinMode(PIN_MOTOR_REVERSE, OUTPUT);
    pinMode(PIN_MOTOR_ENABLE, OUTPUT);
    pinMode(PIN_SOURCE_VOLTAGE, INPUT);
    pinMode(PIN_ENCODER_A, INPUT_PULLUP);
    pinMode(PIN_ENCODER_B, INPUT_PULLUP);
    
    attachInterrupt(digitalPinToInterrupt(PIN_ENCODER_A), _encoderISR, CHANGE);
    attachInterrupt(digitalPinToInterrupt(PIN_ENCODER_B), _encoderISR, CHANGE);
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

void setMotorEnabled(bool enabled) {
    digitalWrite(PIN_MOTOR_ENABLE, enabled);
    _motorEnabled = enabled;
}
void driveDutyCycle(float dutyCycle) {
    dutyCycle = min(max(dutyCycle, -1), 1);
    _commandedOutput = dutyCycle;
    
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
void stop() {
    driveDutyCycle(0);
}
float getSourceVoltage() {
    const int R1 = 969; //r1 value in the voltage divider ; 1000 ohm resistor with 5% tolerance, measured with multimeter
    const int R2 = 542; //r2 value in the voltage divider ; 560 ohm resistor with 5% tolerance, measured with multimeter
    const float REF_VOLTAGE = 4.8; //should be 5 V but the voltage regulator isn't perfect
    
    float percent = analogRead(PIN_SOURCE_VOLTAGE) / 1023.0;
    //V_in = (V_s * R2) / (R1 + R2)
    //perc = V_in / V_r
    //therefore:
    //V_s = perc * V_r * (R1 + R2) / R2
    return percent * REF_VOLTAGE * (R1 + R2) / R2;
}
void driveVoltage(float volts) {
    if(getSourceVoltage() == 0) {
        stop();
    }
    else {
        driveDutyCycle(volts / getSourceVoltage());
    }
}
void drivePIDToPosition(float targetTicks) {
    driveDutyCycle(_calcPIDS((float) getEncoderTicks(), targetTicks, _kP, _kI, _kD, _kS, KS_MODE_ERROR));
}
void drivePIDToVelocity(float targetTPS) {
    driveDutyCycle(_calcPIDS((float) getEncoderTicksPerSecond(), targetTPS, _kP, _kI, _kD, _kS, KS_MODE_VELOCITY));
}
void driveProfileToPosition(float targetTicks) {
    float profileOutput = _calcProfile((float) getEncoderTicks(), targetTicks, _vMax, _aStart, _aEnd);
    
    return driveDutyCycle(_calcPIDS((float) getEncoderTicks(), profileOutput, _kP, _kI, _kD, _kS, KS_MODE_VELOCITY));
}

void setControlMode(ControlMode mode) {
    _controlMode = mode;
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

bool getMotorEnabled() {
    return _motorEnabled;
}
ControlMode* getControlMode() {
    return &_controlMode;
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
float getCommandedOutput() {
    return _commandedOutput;
}
float getMostRecentPIDError() {
    return _lastPIDError;
}

float _calcPIDS(float current, float target, float kP, float kI, float kD, float kS, int kSMode) {
    float error = target - current;
    
    unsigned long currentMicros = micros();
    if(_resetPIDMicrosFlag) {
        _lastPIDMicros = currentMicros;
        _resetPIDMicrosFlag = false;
    }
    unsigned long deltaMicros = currentMicros - _lastPIDMicros;
    _lastPIDMicros = currentMicros;
    
    float p = kP * error;
    float i = kI * _iAccumlated;
    float d;
    if(deltaMicros == 0) {
        d = 0; //prevent divide by zero
    }
    else {
        d = kD * (error - _lastPIDError) / deltaMicros * 1e6;
    }
    
    _iAccumlated = min(max(_iAccumlated + error, -1 / kI), 1 / kI); //prevent integral windup
    _lastPIDError = error;
    
    float pid = p + i + d;
    float kSRef;
    
    /*
    From Phoenix 6 Slot0Configs.StaticFeedforwardSign:
    
    "The default behavior uses the velocity reference sign. This works well with velocity closed loop, Motion Magic® controls, and position closed loop when velocity reference is specified (motion profiling).

However, when using position closed loop with zero velocity reference (no motion profiling), the application may want to apply static feedforward based on the sign of closed loop error instead. When doing so, we recommend using the minimal amount of kS, otherwise the motor output may dither when closed loop error is near zero."
    */
    switch(kSMode) {
        default:
        case KS_MODE_ERROR: {
            kSRef = error;
        }
        case KS_MODE_VELOCITY: {
            kSRef = getEncoderTicksPerSecond();
        }
    }
    return pid + kS * sign(kSRef);
}
void resetPID() {
    _iAccumlated = 0;
    _lastPIDError = 0;
    _resetPIDMicrosFlag = true;
}
void setKP(float kP) {
    _kP = kP;
}
void setKI(float kI) {
    _kI = kI;
}
void setKD(float kD) {
    _kD = kD;
}
void setKS(float kS) {
    _kS = kS;
}

float _calcProfile(float current, float target, float vMax, float aStart, float aEnd) {
    //https://www.desmos.com/calculator/1rzl2ysfkp
    
    unsigned long currentTime = micros();
    double timeSinceStart = (currentTime - _profileStartMicros) / 1e6;
    
    if(isnan(_profileStartTicks)) {
        _profileStartTicks = current;
    }
    
    float deltaPos = target - _profileStartTicks;
    double vel = sign(deltaPos) * min(sqrt(2 * abs(deltaPos) / (1 / aStart + 1 / aEnd)), vMax);
    
    float tAccel = abs(vel) / aStart;
    float posAccel = tAccel * vel / 2.0;
    
    float tDeccel = abs(vel) / aEnd;
    float posDeccel = tDeccel * vel / 2.0;
    
    float posConst = deltaPos - posAccel - posDeccel;
    float tConst = vel == 0.0 ? 0 : abs(posConst / vel);
    
    double iAccel = min(timeSinceStart, tAccel);
    double iConst = min(max(timeSinceStart - tAccel, 0), tConst);
    double iDeccel = min(max(timeSinceStart - tAccel - tConst, 0), tDeccel);
    
    float accelSeg = aStart / 2 * iAccel * iAccel;
    float constSeg = abs(vel) * iConst;
    float deccelSeg = -aEnd / 2 * iDeccel * iDeccel + abs(vel) * iDeccel;
    
    return _profileStartTicks + sign(vel) * (accelSeg + constSeg + deccelSeg);
}
void resetProfile() {
    _profileStartMicros = micros();
    _profileStartTicks = NAN;
}
void setVMax(float vMax) {
    _vMax = vMax;
}
void setAStart(float aStart) {
    _aStart = aStart;
}
void setAEnd(float aEnd) {
    _aEnd = aEnd;
}
