#pragma once

#include <Arduino.h>

#define PIN_MOTOR_FORWARD 5
#define PIN_MOTOR_REVERSE 6
#define PIN_MOTOR_ENABLE 4
#define PIN_ENCODER_A 2
#define PIN_ENCODER_B 3

#define USE_EXTERNAL_AREF true //WARNING: making this false while AREF isn't floating WILL SHORT OUT the arduino
#define PIN_SOURCE_VOLTAGE A0
#define SV_R1 5030 //r1 value in the voltage divider ; 5k1 resistor with 1% tolerance, measured with multimeter
#define SV_R2 (985 + 324) //r2 value in the voltage divider ; 1k resistor and 330 resistor with 1% tolerance, measured with multimeter
#define SV_SAMPLE_COUNT 16
#if USE_EXTERNAL_AREF
#define VREF 2.5
#else
#define VREF 4.24
#endif

#define INVERT_ENCODER false
#define ENCODER_TICKS_PER_ROTATION 400

#define _ENCODER_SIGNAL_A 0b00000100
#define _ENCODER_SIGNAL_B 0b00001000
#define _ENCODER_SIGNAL_AB 0b00001100

void initHardware();

void setMotorEnabled(bool enabled);
bool getMotorEnabled();
void dutyCycle(double dutyCycle);
void updateSourceVoltage();
double getSourceVoltage();

void _encoderISR();
void updateVelocity();
long getEncoderTicks();
double getEncoderRotations();
double getEncoderTicksPerSecond();
double getEncoderRPM();
