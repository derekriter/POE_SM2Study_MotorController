#pragma once

#include <Arduino.h>
#include "controlSlot.hpp"

class ControlMode {
    public:
        virtual ~ControlMode() {};
    
        virtual void update(unsigned long deltaMicros, struct SlotConfig const * const slots) = 0;
        virtual uint8_t const getID() const = 0;
        virtual void getControlModeData(struct ControlModeData* data) = 0;
};

class DisabledControlMode : public ControlMode {
    public:
        void update(unsigned long deltaMicros, struct SlotConfig const * const slots) override;
        uint8_t const getID() const override;
        void getControlModeData(struct ControlModeData* data) override;
};

class StopControlMode : public ControlMode {
    public:
        void update(unsigned long deltaMicros, struct SlotConfig const * const slots) override;
        uint8_t const getID() const override;
        void getControlModeData(struct ControlModeData* data) override;
};

class DutyCycleControlMode : public ControlMode {
    public:
        explicit DutyCycleControlMode(double dutyCycle);
        
        void update(unsigned long deltaMicros, struct SlotConfig const * const slots) override;
        uint8_t const getID() const override;
        void getControlModeData(struct ControlModeData* data) override;
        
        static bool parseFromCommandArgs(char const * const commandArgs, DutyCycleControlMode** const controlOut);
    
    private:
        double _duty;
};

class VoltageControlMode : public ControlMode {
    public:
        explicit VoltageControlMode(double voltage);
        
        void update(unsigned long deltaMicros, struct SlotConfig const * const slots) override;
        uint8_t const getID() const override;
        void getControlModeData(struct ControlModeData* data) override;
        
        static bool parseFromCommandArgs(char const * const commandArgs, VoltageControlMode** const controlOut);
    
    private:
        double _voltage;
        double _lastDuty;
};

class PIDPositionControlMode : public ControlMode {
    public:
        PIDPositionControlMode(double targetRots, uint8_t slot);
        
        void update(unsigned long deltaMicros, struct SlotConfig const * const slots) override;
        uint8_t const getID() const override;
        void getControlModeData(struct ControlModeData* data) override;
        
        static bool parseFromCommandArgs(char const * const commandArgs, PIDPositionControlMode** const controlOut);
        
    private:
        double _target;
        uint8_t _slot;
        double _lastDuty;
        double _lastError;
        double _iAccum;
        
        unsigned int _updatesSinceLastFrame;
        double _totalP, _totalI, _totalD, _totalF, _totalS;
};

class PIDVelocityControlMode : public ControlMode {
    public:
        PIDVelocityControlMode(double targetRPM, uint8_t slot);
        
        void update(unsigned long deltaMicros, struct SlotConfig const * const slots) override;
        uint8_t const getID() const override;
        void getControlModeData(struct ControlModeData* data) override;
        
        static bool parseFromCommandArgs(char const * const commandArgs, PIDVelocityControlMode** const controlOut);
        
    private:
        double _target;
        uint8_t _slot;
        double _lastDuty;
        double _lastError;
        double _iAccum;
        
        unsigned int _updatesSinceLastFrame;
        double _totalP, _totalI, _totalD, _totalF, _totalS, _totalV;
};

class TrapezoidalPIDPositionControlMode : public ControlMode {
    public:
        TrapezoidalPIDPositionControlMode(double targetRots, uint8_t slot);
        
        
        void update(unsigned long deltaMicros, struct SlotConfig const * const slots) override;
        uint8_t const getID() const override;
        void getControlModeData(struct ControlModeData* data) override;
        
        static bool parseFromCommandArgs(char const * const commandArgs, TrapezoidalPIDPositionControlMode** const controlOut);
    
    private:
        double _target;
        uint8_t _slot;
        double _lastDuty;
        double _lastMajorError;
        double _lastMinorError;
        double _iAccum;
        unsigned long _microsSinceStart;
        double _startRots;
        uint8_t _lastPhase;
        double _lastSecsToCompletion;
        
        unsigned int _updatesSinceLastFrame;
        double _totalP, _totalI, _totalD, _totalF, _totalS;
};
