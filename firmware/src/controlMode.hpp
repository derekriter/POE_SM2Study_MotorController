#pragma once

#include <Arduino.h>
#include "controlSlot.hpp"

class ControlMode {
    public:
        virtual ~ControlMode() {};
    
        virtual void update(unsigned long deltaMicros, const struct SlotConfig* slots) = 0;
        virtual uint8_t getID() = 0;
        virtual char* getControlModeData() = 0;
};

class DisabledControlMode : public ControlMode {
    public:
        void update(unsigned long deltaMicros, const struct SlotConfig* slots) override;
        uint8_t getID() override;
        char* getControlModeData() override;
};

class StopControlMode : public ControlMode {
    public:
        void update(unsigned long deltaMicros, const struct SlotConfig* slots) override;
        uint8_t getID() override;
        char* getControlModeData() override;
};

class DutyCycleControlMode : public ControlMode {
    public:
        DutyCycleControlMode(double dutyCycle);
        
        void update(unsigned long deltaMicros, const struct SlotConfig* slots) override;
        uint8_t getID() override;
        char* getControlModeData() override;
        
        static bool parseFromCommandArgs(const char* commandArgs, DutyCycleControlMode** controlOut);
    
    private:
        double _duty;
};

class VoltageControlMode : public ControlMode {
    public:
        VoltageControlMode(double voltage);
        
        void update(unsigned long deltaMicros, const struct SlotConfig* slots) override;
        uint8_t getID() override;
        char* getControlModeData() override;
        
        static bool parseFromCommandArgs(const char* commandArgs, VoltageControlMode** controlOut);
    
    private:
        double _voltage;
        double _lastDuty;
};
