#pragma once

#include <Arduino.h>

class ControlMode {
    public:
        virtual ~ControlMode() {};
    
        virtual void update(unsigned long deltaMicros) = 0;
        virtual uint8_t getID() = 0;
        virtual char* getControlModeData() = 0;
};

class DisabledControlMode : public ControlMode {
    public:
        void update(unsigned long deltaMicros) override;
        uint8_t getID() override;
        char* getControlModeData() override;
};

class StopControlMode : public ControlMode {
    public:
        void update(unsigned long deltaMicros) override;
        uint8_t getID() override;
        char* getControlModeData() override;
};

class DutyCycleControlMode : public ControlMode {
    public:
        DutyCycleControlMode(double dutyCycle);
        
        void update(unsigned long deltaMicros) override;
        uint8_t getID() override;
        char* getControlModeData() override;
        
        static bool parseFromCommandArgs(const char* commandArgs, DutyCycleControlMode** controlOut);
    
    private:
        double _duty;
};
