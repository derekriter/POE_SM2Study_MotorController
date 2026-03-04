#pragma once

#include <Arduino.h>
#include "controlMode.hpp"

#define SEVERITY_INFO 0x0u
#define SEVERITY_WARNING 0x1u
#define SEVERITY_ERROR 0x2u

#define NO_CHANGE 0
#define SET_ENABLE 1
#define SET_DISABLE 2

struct DataFrame {
    bool enabled;
    double sourceVoltage;
    double position;
    double velocity;
    const char* controlModeData;
    unsigned long millis;
};
struct MessageFrame {
    uint8_t severity;
    const char* message;
};
struct SlotFrame {
    uint8_t slotNum;
    double kP, kI, kD, kS;
    uint8_t kSMode;
    double vMax, aStart, aEnd;
};

struct ReceivedCommand {
    int changeEnabled; //either NO_CHANGE, SET_ENABLE, or SET_DISABLE
    struct ControlMode* changeControlMode;
    struct SlotConfig* changeSlotConfig;
    uint8_t changeSlotNum;
    uint8_t getSlotNum;
};

void sendDataFrame(const DataFrame* data);
void sendMessageFrame(const MessageFrame* msg);
void sendOKFrame();
void sendSlotFrame(const SlotFrame* slot);

bool getIncomingIfAvailable(String* incoming);
bool processCommand(const String* command, ReceivedCommand* instructions);
