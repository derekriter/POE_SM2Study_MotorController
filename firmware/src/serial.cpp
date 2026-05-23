#include "serial.hpp"
#include "util.hpp"
#include "controlMode.hpp"

void sendDataFrame(DataFrame const * const data) {
    Serial.print(F("{\"ty\":\"data\",\"py\":{"));
    
    Serial.print(F("\"en\":"));
    Serial.print(data->enabled ? F("true") : F("false"));
    
    Serial.print(F(",\"sv\":"));
    Serial.print(data->sourceVoltage, 4);
    
    Serial.print(F(",\"pr\":"));
    Serial.print(data->position, 4);
    
    Serial.print(F(",\"vr\":"));
    Serial.print(data->velocity, 4);
    
    Serial.print(F(",\"cm\":{\"id\":"));
    Serial.print(data->controlModeData->controlID);
    Serial.print(F(",\"do\":"));
    Serial.print(data->controlModeData->dutyOut, 3);
    Serial.print(F(",\"vo\":"));
    Serial.print(data->controlModeData->voltageOut, 3);
    if(data->controlModeData->hasTarget) {
        Serial.print(F(",\"ct\":"));
        Serial.print(data->controlModeData->target, 4);
    }
    if(data->controlModeData->hasError) {
        Serial.print(F(",\"ce\":"));
        Serial.print(data->controlModeData->error, 4);
    }
    if(data->controlModeData->hasPFactor) {
        Serial.print(F(",\"cp\":"));
        Serial.print(data->controlModeData->pFactor, 3);
    }
    if(data->controlModeData->hasIFactor) {
        Serial.print(F(",\"ci\":"));
        Serial.print(data->controlModeData->iFactor, 3);
    }
    if(data->controlModeData->hasDFactor) {
        Serial.print(F(",\"cd\":"));
        Serial.print(data->controlModeData->dFactor, 3);
    }
    if(data->controlModeData->hasFFactor) {
        Serial.print(F(",\"cf\":"));
        Serial.print(data->controlModeData->fFactor, 3);
    }
    if(data->controlModeData->hasSFactor) {
        Serial.print(F(",\"cs\":"));
        Serial.print(data->controlModeData->sFactor, 3);
    }
    if(data->controlModeData->hasVFactor) {
        Serial.print(F(",\"cv\":"));
        Serial.print(data->controlModeData->vFactor, 3);
    }
    if(data->controlModeData->hasSlot) {
        Serial.print(F(",\"sl\":"));
        Serial.print(data->controlModeData->slot);
    }
    if(data->controlModeData->hasSubError) {
        Serial.print(F(",\"se\":"));
        Serial.print(data->controlModeData->subError, 4);
    }
    if(data->controlModeData->hasSecsToCompletion) {
        Serial.print(F(",\"tc\":"));
        Serial.print(data->controlModeData->secsToCompletion, 3);
    }
    if(data->controlModeData->hasPhase) {
        Serial.print(F(",\"ph\":"));
        Serial.print(data->controlModeData->phase);
    }
    
    Serial.print(F("},\"ms\":"));
    Serial.print(data->millis);
    
    Serial.println(F("}}"));
}
void sendMessageFrame(MessageFrame const * const msg) {
    Serial.print(F("{\"ty\":\"msg\",\"py\":{"));
    
    Serial.print(F("\"sv\":"));
    Serial.print(msg->severity);
    
    Serial.print(F(",\"msg\":\""));
    Serial.print(msg->message);
    
    Serial.println(F("\"}}"));
}
void sendMessageFrameP(MessageFrameP const * const msgP) {
    Serial.print(F("{\"ty\":\"msg\",\"py\":{"));
    
    Serial.print(F("\"sv\":"));
    Serial.print(msgP->severity);
    
    Serial.print(F(",\"msg\":\""));
    Serial.print(msgP->messageP);
    
    Serial.println(F("\"}}"));
}
void sendOKFrame() {
    Serial.println(F("{\"ty\":\"ok\"}"));
}
void sendSlotFrame(SlotFrame const * const slot) {
    Serial.print(F("{\"ty\":\"slot\",\"py\":{"));
    
    Serial.print(F("\"sn\":"));
    Serial.print(slot->slotNum);
    
    Serial.print(F(",\"kp\":"));
    Serial.print(slot->kP, 8);
    
    Serial.print(F(",\"ki\":"));
    Serial.print(slot->kI, 8);
    
    Serial.print(F(",\"kd\":"));
    Serial.print(slot->kD, 8);
    
    Serial.print(F(",\"kf\":"));
    Serial.print(slot->kF, 3);
    
    Serial.print(F(",\"ks\":"));
    Serial.print(slot->kS, 3);
    
    Serial.print(F(",\"kv\":"));
    Serial.print(slot->kV, 8);
    
    Serial.print(F(",\"sm\":"));
    Serial.print(slot->kSMode);
    
    Serial.print(F(",\"vm\":"));
    Serial.print(slot->vMax, 2);
    
    Serial.print(F(",\"as\":"));
    Serial.print(slot->aStart, 2);
    
    Serial.print(F(",\"ae\":"));
    Serial.print(slot->aEnd, 2);
    
    Serial.println(F("}}"));
}
void sendDeviceInfo() {
    Serial.print(F("{\"ty\":\"info\",\"py\":{"));
    
    Serial.print(F("\"nm\":\""));
    Serial.print(DEVICE_NAME);
    
    Serial.print(F("\",\"fv\":\""));
    Serial.print(FIRMWARE_VERSION);
    
    Serial.println(F("\"}}"));
}

bool getIncomingIfAvailable(String* const incoming) {
    if(!Serial.available()) return false;
    
    *incoming = Serial.readStringUntil('\0');
    return true;
}
bool processCommand(String const * const command, ReceivedCommand* const instructions) {
    char const * commandCstr = command->c_str();
    
    if(strcmp_P(commandCstr, (char const *) F("enable")) == 0) {
        *instructions = ReceivedCommand {
            SET_ENABLE,
            nullptr,
            nullptr,
            static_cast<uint8_t>(NULL),
            NO_CHANGE
        };
        
        sendOKFrame();
        return true;
    }
    else if(strcmp_P(commandCstr, (char const *) F("disable")) == 0) {
        *instructions = ReceivedCommand {
            SET_DISABLE,
            nullptr,
            nullptr,
            static_cast<uint8_t>(NULL),
            NO_CHANGE
        };
        
        sendOKFrame();
        return true;
    }
    else if(strcmp_P(commandCstr, (char const *) F("stop")) == 0) {
        *instructions = ReceivedCommand {
            NO_CHANGE,
            new StopControlMode(),
            nullptr,
            static_cast<uint8_t>(NULL),
            NO_CHANGE
        };
        
        sendOKFrame();
        return true;
    }
    else if(startsWithP(commandCstr, F("dutyCycle "))) {
        DutyCycleControlMode* control = nullptr;
        if(DutyCycleControlMode::parseFromCommandArgs(commandCstr + 10, &control)) {
            *instructions = ReceivedCommand {
                NO_CHANGE,
                control,
                nullptr,
                static_cast<uint8_t>(NULL),
                NO_CHANGE
            };
            
            sendOKFrame();
            return true;
        }
        
        return false;
    }
    else if(startsWithP(commandCstr, F("voltage "))) {
        VoltageControlMode* control = nullptr;
        if(VoltageControlMode::parseFromCommandArgs(commandCstr + 8, &control)) {
            *instructions = ReceivedCommand {
                NO_CHANGE,
                control,
                nullptr,
                static_cast<uint8_t>(NULL),
                NO_CHANGE
            };
            
            sendOKFrame();
            return true;
        }
        
        return false;
    }
    else if(startsWithP(commandCstr, F("pidPos "))) {
        PIDPositionControlMode* control = nullptr;
        if(PIDPositionControlMode::parseFromCommandArgs(commandCstr + 7, &control)) {
            *instructions = ReceivedCommand {
                NO_CHANGE,
                control,
                nullptr,
                static_cast<uint8_t>(NULL),
                NO_CHANGE
            };
            
            sendOKFrame();
            return true;
        }
        
        return false;
    }
    else if(startsWithP(commandCstr, F("pidVel "))) {
        PIDVelocityControlMode* control = nullptr;
        if(PIDVelocityControlMode::parseFromCommandArgs(commandCstr + 7, &control)) {
            *instructions = ReceivedCommand {
                NO_CHANGE,
                control,
                nullptr,
                static_cast<uint8_t>(NULL),
                NO_CHANGE
            };
            
            sendOKFrame();
            return true;
        }
        
        return false;
    }
    else if(startsWithP(commandCstr, F("trapPos "))) {
        TrapezoidalPIDPositionControlMode* control = nullptr;
        if(TrapezoidalPIDPositionControlMode::parseFromCommandArgs(commandCstr + 8, &control)) {
            *instructions = ReceivedCommand {
                NO_CHANGE,
                control,
                nullptr,
                static_cast<uint8_t>(NULL),
                NO_CHANGE
            };
            
            sendOKFrame();
            return true;
        }
        
        return false;
    }
    else if(startsWithP(commandCstr, F("setSlot "))) {
        SlotConfig* slot = nullptr;
        uint8_t slotNum = static_cast<uint8_t>(NULL);
        if(parseSlotConfigFromCommandArgs(commandCstr + 8, &slot, &slotNum)) {
            *instructions = ReceivedCommand {
                NO_CHANGE,
                nullptr,
                slot,
                slotNum,
                NO_CHANGE
            };
            
            sendOKFrame();
            return true;
        }
        
        return false;
    }
    else if(startsWithP(commandCstr, F("getSlot "))) {
        uint8_t slotNum;
        char* arg2Start;
        if(!parseUInt(command->c_str() + 8, &slotNum, &arg2Start)) {
            const MessageFrameP msg =  {SEVERITY_ERROR, F("Malformed getSlot, failed to parse arg1 as a uint8_t")};
            sendMessageFrameP(&msg);
            
            return false;
        }
        if(slotNum >= 6) {
            const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed getSlot, slotNum must be in range [0, 5]")};
            sendMessageFrameP(&msg);
            
            return false;
        }
        
        if(*arg2Start != '\0') {
            const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed getSlot, too many arguments")};
            sendMessageFrameP(&msg);
            
            return false;
        }
        
        *instructions = ReceivedCommand {
            NO_CHANGE,
            nullptr,
            nullptr,
            static_cast<uint8_t>(NULL),
            slotNum
        };
        
        sendOKFrame();
        return true;
    }
    else if(strcmp_P(commandCstr, (const char*) F("getInfo")) == 0) {
        sendDeviceInfo();
        sendOKFrame();
        return false;
    }
    else {
        size_t len = strlen_P((char const *) F("Unknown command ''")) + strlen(commandCstr) + 1;
        char* msg = static_cast<char*>(malloc(len));
        snprintf_P(msg, len, (char const *) F("Unknown command '%s'"), commandCstr);
        
        MessageFrame frame = {SEVERITY_ERROR, msg};
        sendMessageFrame(&frame);
        free(msg);
        
        return false;
    }
}
