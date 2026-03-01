#pragma once

#include <Arduino.h>
#include "controlMode.hpp"

#define PIN_MOTOR_FORWARD 5
#define PIN_MOTOR_REVERSE 6
#define PIN_MOTOR_ENABLE 4
#define PIN_SOURCE_VOLTAGE A0
#define PIN_ENCODER_A 2
#define PIN_ENCODER_B 3

#define KS_MODE_ERROR 0
#define KS_MODE_VELOCITY 1

#define INVERT_ENCODER false
#define ENCODER_TICKS_PER_ROTATION 400

#define _ENCODER_SIGNAL_A 0b00000100
#define _ENCODER_SIGNAL_B 0b00001000
#define _ENCODER_SIGNAL_AB 0b00001100

void setupPins();
void _encoderISR();

void setMotorEnabled(bool enabled);
void driveDutyCycle(float dutyCycle);
void stop();
float getSourceVoltage();
void driveVoltage(float volts);
void drivePIDToPosition(float targetTicks);
void drivePIDToVelocity(float targetTPS);
void driveProfileToPosition(float targetTicks);

void setControlMode(ControlMode mode);
void setControlReference(float ref);

void updateVelocity();

bool getMotorEnabled();
ControlMode* getControlMode();
long getEncoderTicks();
double getEncoderRotations();
double getEncoderTicksPerSecond();
double getEncoderRPM();
float getCommandedOutput();
float getMostRecentPIDError();

float _calcPIDS(float current, float target, float kP, float kI, float kD, float kS, int kSMode);
void resetPID();
void setKP(float kP);
void setKI(float kI);
void setKD(float kD);
void setKS(float kS);

float _calcProfile(float current, float target, float vMax, float aStart, float aEnd);
void resetProfile();
void setVMax(float vMax);
void setAStart(float aStart);
void setAEnd(float aEnd);
