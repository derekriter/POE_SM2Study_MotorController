#pragma once

#include <Arduino.h>
#include "controlSlot.hpp"

class ControlMode {
    public:
        virtual ~ControlMode() {};
    
        virtual void update(unsigned long deltaMicros, struct SlotConfig const * const slots) = 0;
        virtual const uint8_t getID() const = 0;
        virtual char* getControlModeData() const = 0;
};

class DisabledControlMode : public ControlMode {
    public:
        void update(unsigned long deltaMicros, struct SlotConfig const * const slots) override;
        const uint8_t getID() const override;
        char* getControlModeData() const override;
};

class StopControlMode : public ControlMode {
    public:
        void update(unsigned long deltaMicros, struct SlotConfig const * const slots) override;
        const uint8_t getID() const override;
        char* getControlModeData() const override;
};

class DutyCycleControlMode : public ControlMode {
    public:
        explicit DutyCycleControlMode(double dutyCycle);
        
        void update(unsigned long deltaMicros, struct SlotConfig const * const slots) override;
        const uint8_t getID() const override;
        char* getControlModeData() const override;
        
        static bool parseFromCommandArgs(char const * const commandArgs, DutyCycleControlMode** const controlOut);
    
    private:
        double _duty;
};

class VoltageControlMode : public ControlMode {
    public:
        explicit VoltageControlMode(double voltage);
        
        void update(unsigned long deltaMicros, struct SlotConfig const * const slots) override;
        const uint8_t getID() const override;
        char* getControlModeData() const override;
        
        static bool parseFromCommandArgs(char const * const commandArgs, VoltageControlMode** const controlOut);
    
    private:
        double _voltage;
        double _lastDuty;
};
