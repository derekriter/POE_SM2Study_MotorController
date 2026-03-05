#pragma once

#include <Arduino.h>

bool startsWith(const char* str, const char* prefix);
bool startsWithP(const char* str, const __FlashStringHelper* prefixP);
int sign(float val);
bool parseDouble(const char* str, double* out, char** end);
bool parseUInt(const char* str, uint8_t* out, char** end);
