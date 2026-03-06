#pragma once

#include <Arduino.h>

#include "controlSlot.hpp"

bool startsWith(char const * const str, char const * const prefix);
bool startsWithP(char const * const str, __FlashStringHelper const * const prefixP);
int sign(float val);
bool parseDouble(char const * const str, double* const out, char** const end);
bool parseUInt(char const * const str, uint8_t* const out, char** const end);
double calcPIDS(double currentVal, double target, struct SlotConfig const * config, unsigned long deltaMicros, double lastErr, double* errOut, double* pOut, double* iOut, double* iAccum, double* dOut, double* sOut);
