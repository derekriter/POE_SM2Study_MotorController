#pragma once

#include <Arduino.h>

#define PIN_MOTOR_FORWARD 5
#define PIN_MOTOR_REVERSE 6
#define PIN_MOTOR_ENABLE 4
#define PIN_SOURCE_VOLTAGE A0
#define PIN_ENCODER_A 2
#define PIN_ENCODER_B 3

#define INVERT_ENCODER false
#define ENCODER_TICKS_PER_ROTATION 400

#define _ENCODER_SIGNAL_A 0b00000100
#define _ENCODER_SIGNAL_B 0b00001000
#define _ENCODER_SIGNAL_AB 0b00001100

void initHardware();

void setMotorEnabled(bool enabled);
bool getMotorEnabled();
void dutyCycle(double dutyCycle);
double getSourceVoltage();

void _encoderISR();
void updateVelocity();
long getEncoderTicks();
double getEncoderRotations();
double getEncoderTicksPerSecond();
double getEncoderRPM();
