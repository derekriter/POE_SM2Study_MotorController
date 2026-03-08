#pragma once

#include <Arduino.h>

#include "controlSlot.hpp"

bool startsWith(char const * const str, char const * const prefix);
bool startsWithP(char const * const str, __FlashStringHelper const * const prefixP);
int sign(double val);
bool parseDouble(char const * const str, double* const out, char** const end);
bool parseUInt(char const * const str, uint8_t* const out, char** const end);
double calcPIDS(double currentVal, double target, struct SlotConfig const * config, unsigned long deltaMicros, double* lastError, double* pFactor, double* iFactor, double* iAccum, double* dFactor, double* sFactor);
double calcTrapProfile(unsigned long microsSinceStart, double startPos, double targetPos, struct SlotConfig const * config);
