#pragma once

#include <Arduino.h>

bool startsWith(char const * const str, char const * const prefix);
bool startsWithP(char const * const str, __FlashStringHelper const * const prefixP);
int sign(float val);
bool parseDouble(char const * const str, double* const out, char** const end);
bool parseUInt(char const * const str, uint8_t* const out, char** const end);
