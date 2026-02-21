#pragma once

#include <Arduino.h>

#define SEVERITY_WARNING 0
#define SEVERITY_ERROR 1

void sendDataFrame(double avgTPS, float avgErr);
void sendBadFrame(const char* msg, uint8_t severity);
bool getIncomingIfAvailable(String* incoming);
void processCommand(const String* command);
void sendMessageFrame(const char* msg);
void sendOKFrame();
