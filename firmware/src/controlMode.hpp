#pragma once

#include <Arduino.h>

class ControlMode {
    public:
        virtual ~ControlMode() {};
    
        virtual void update(unsigned long deltaMicros) = 0;
        virtual uint8_t getID() = 0;
};

class StopControlMode : public ControlMode {
    public:
        void update(unsigned long deltaMicros) override;
        uint8_t getID() override;
        
        static bool parseFromCommandArgs(const char* commandArgs, StopControlMode** controlOut);
};

class DutyCycleControlMode : public ControlMode {
    public:
        DutyCycleControlMode(double dutyCycle);
        
        void update(unsigned long deltaMicros) override;
        uint8_t getID() override;
        
        static bool parseFromCommandArgs(const char* commandArgs, DutyCycleControlMode** controlOut);
    
    private:
        double _duty;
};
