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
    const char* controlModeData;
    double position;
    double velocity;
    double commandedOutput;
};
struct MessageFrame {
    uint8_t severity;
    const char* message;
};

struct ReceivedCommand {
    int changeEnabled; //either NO_CHANGE, SET_ENABLE, or SET_DISABLE
    ControlMode* changeControlMode;
};

void sendDataFrame(const DataFrame* data);
void sendMessageFrame(const MessageFrame* msg);
void sendOKFrame();

bool getIncomingIfAvailable(String* incoming);
bool processCommand(const String* command, ReceivedCommand* instructions);
