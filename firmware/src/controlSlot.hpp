#pragma once

#include <Arduino.h>
#include "serial.hpp"

#define KS_MODE_ERROR_BASED 0x00u
#define KS_MODE_VELOCITY_BASED 0x01u

struct SlotConfig {
    double kP, kI, kD, kS;
    uint8_t kSMode;
    double vMax, aStart, aEnd;
};

bool parseSlotConfigFromCommandArgs(const char* commandArgs, SlotConfig** slotOut, uint8_t* slotNumOut);
