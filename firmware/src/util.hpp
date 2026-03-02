#pragma once

#include <Arduino.h>

int sign(float val);
bool parseDouble(const char* str, double* out, char** end);
