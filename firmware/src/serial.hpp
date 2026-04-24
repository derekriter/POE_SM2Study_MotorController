#pragma once

#include <Arduino.h>
#include "controlMode.hpp"

#define SEVERITY_INFO 0x0u
#define SEVERITY_WARNING 0x1u
#define SEVERITY_ERROR 0x2u

#define NO_CHANGE 255u
#define SET_ENABLE 1u
#define SET_DISABLE 2u

#define DEVICE_NAME F("Custom Motor Controller v1.0")
#define FIRMWARE_VERSION F("v2.0")

struct ControlModeData {
    uint8_t controlID;
    double dutyOut;
    double voltageOut;
    
    bool hasTarget;
    double target;
    bool hasError;
    double error;
    bool hasPFactor;
    double pFactor;
    bool hasIFactor;
    double iFactor;
    bool hasDFactor;
    double dFactor;
    bool hasSFactor;
    double sFactor;
    bool hasSlot;
    uint8_t slot;
    bool hasSubError;
    double subError;
    bool hasSecsToCompletion;
    double secsToCompletion;
    bool hasPhase;
    uint8_t phase;
};
struct DataFrame {
    bool enabled;
    double sourceVoltage;
    double position;
    double velocity;
    ControlModeData const * controlModeData;
    unsigned long millis;
};
struct MessageFrame {
    uint8_t severity;
    char const * message;
};
struct MessageFrameP {
    uint8_t severity;
    __FlashStringHelper const * messageP;
};
struct SlotFrame {
    uint8_t slotNum;
    double kP, kI, kD, kS;
    uint8_t kSMode;
    double vMax, aStart, aEnd;
};

struct ReceivedCommand {
    int changeEnabled; //either NO_CHANGE, SET_ENABLE, or SET_DISABLE
    struct ControlMode* changeControlMode; //nullptr if none
    struct SlotConfig* changeSlotConfig; //nullptr if none
    uint8_t changeSlotNum; //NULL if none
    uint8_t getSlotNum; //either a slot num or NO_CHANGE
};

void sendDataFrame(DataFrame const * const data);
void sendMessageFrame(MessageFrame const * const msg);
void sendMessageFrameP(MessageFrameP const * const msgP);
void sendOKFrame();
void sendSlotFrame(SlotFrame const * const slot);
void sendDeviceInfo();

bool getIncomingIfAvailable(String* const incoming);
bool processCommand(String const * const command, ReceivedCommand* const instructions);
