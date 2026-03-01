#pragma once

#include <Arduino.h>

bool startsWith(const char* str, const char* prefix);
int sign(float val);
bool parseDouble(const char* str, double* out, char** end);
