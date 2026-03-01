#pragma once

#include <Arduino.h>

class ControlMode {
    public:
        ControlMode() {}
    
        virtual void update(unsigned long deltaMicros) {}
        virtual uint8_t getID() {return 2;}
};

class StopControlMode : public ControlMode {
    public:
        StopControlMode();
    
        void update(unsigned long deltaMicros) override;
        uint8_t getID() override;
        
        static bool parseFromCommandArgs(const char* commandArgs, StopControlMode* controlOut);
};

class DutyCycleControlMode : public ControlMode {
    public:
        DutyCycleControlMode(double dutyCycle);
        
        void update(unsigned long deltaMicros) override;
        uint8_t getID() override;
        
        static bool parseFromCommandArgs(const char* commandArgs, DutyCycleControlMode* controlOut);
    
    private:
        double duty;
};
