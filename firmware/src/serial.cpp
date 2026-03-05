#include "serial.hpp"
#include "util.hpp"
#include "controlMode.hpp"

void sendDataFrame(const DataFrame* data) {
    Serial.print(F("{\"ty\":\"data\",\"py\":{"));
    
    Serial.print(F("\"en\":"));
    Serial.print(data->enabled ? F("true") : F("false"));
    
    Serial.print(F(",\"sv\":"));
    Serial.print(data->sourceVoltage, 4);
    
    Serial.print(F(",\"pr\":"));
    Serial.print(data->position, 4);
    
    Serial.print(F(",\"vr\":"));
    Serial.print(data->velocity, 4);
    
    Serial.print(F(",\"cm\":"));
    Serial.print(data->controlModeData);
    
    Serial.print(F(",\"ms\":"));
    Serial.print(data->millis);
    
    Serial.println(F("}}"));
}
void sendMessageFrame(const MessageFrame* msg) {
    Serial.print(F("{\"ty\":\"msg\",\"py\":{"));
    
    Serial.print(F("\"sv\":"));
    Serial.print(msg->severity);
    
    Serial.print(F(",\"msg\":\""));
    Serial.print(msg->message);
    
    Serial.println(F("\"}}"));
}
void sendMessageFrameP(const MessageFrameP* msgP) {
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
void sendSlotFrame(const SlotFrame* slot) {
    Serial.print(F("{\"ty\":\"slot\",\"py\":{"));
    
    Serial.print(F("\"sn\":"));
    Serial.print(slot->slotNum);
    
    Serial.print(F(",\"p\":"));
    Serial.print(slot->kP);
    
    Serial.print(F(",\"i\":"));
    Serial.print(slot->kI);
    
    Serial.print(F(",\"d\":"));
    Serial.print(slot->kD);
    
    Serial.print(F(",\"s\":"));
    Serial.print(slot->kS);
    
    Serial.print(F(",\"sm\":"));
    Serial.print(slot->kSMode);
    
    Serial.print(F(",\"v\":"));
    Serial.print(slot->vMax);
    
    Serial.print(F(",\"as\":"));
    Serial.print(slot->aStart);
    
    Serial.print(F(",\"ae\":"));
    Serial.print(slot->aEnd);
    
    Serial.print(F("}}"));
}

bool getIncomingIfAvailable(String* incoming) {
    if(!Serial.available()) return false;
    
    *incoming = Serial.readStringUntil('\0');
    return true;
}
bool processCommand(const String* command, ReceivedCommand* instructions) {
    const char* commandCstr = command->c_str();
    if(strcmp_P(commandCstr, (const char*) F("enable"))) {
        *instructions = ReceivedCommand {
            SET_ENABLE,
            nullptr,
            nullptr,
            static_cast<uint8_t>(NULL),
            static_cast<uint8_t>(NULL)
        };
        
        sendOKFrame();
        return true;
    }
    else if(strcmp_P(commandCstr, (const char*) F("disable"))) {
        *instructions = ReceivedCommand {
            SET_DISABLE,
            nullptr,
            nullptr,
            static_cast<uint8_t>(NULL),
            static_cast<uint8_t>(NULL)
        };
        
        sendOKFrame();
        return true;
    }
    else if(strcmp_P(commandCstr, (const char*) F("stop"))) {
        *instructions = ReceivedCommand {
            NO_CHANGE,
            new StopControlMode(),
            nullptr,
            static_cast<uint8_t>(NULL),
            static_cast<uint8_t>(NULL)
        };
        
        sendOKFrame();
        return true;
    }
    else if(startsWithP(commandCstr, F("dutyCycle "))) {
        DutyCycleControlMode* control = nullptr;
        if(DutyCycleControlMode::parseFromCommandArgs(command->c_str() + 10, &control)) {
            *instructions = ReceivedCommand {
                NO_CHANGE,
                control,
                nullptr,
                static_cast<uint8_t>(NULL),
                static_cast<uint8_t>(NULL)
            };
            
            sendOKFrame();
            return true;
        }
        
        return false;
    }
    else if(startsWithP(commandCstr, F("voltage "))) {
        VoltageControlMode* control = nullptr;
        if(VoltageControlMode::parseFromCommandArgs(command->c_str() + 8, &control)) {
            *instructions = ReceivedCommand {
                NO_CHANGE,
                control,
                nullptr,
                static_cast<uint8_t>(NULL),
                static_cast<uint8_t>(NULL)
            };
            
            sendOKFrame();
            return true;
        }
        
        return false;
    }
    // else if(command->startsWith("pidPos ")) {
        // setControlMode(CONTROL_MODE_PID_POSITION);
        // resetPID();
        // sendOKFrame();
    // }
    // else if(command->startsWith("pidVel ")) {
        // setControlMode(CONTROL_MODE_PID_VELOCITY);
        // resetPID();
        // sendOKFrame();
    // }
    // else if(command->startsWith("trapPos ")) {
        // setControlMode(CONTROL_MODE_TRAP_POSITION);
        // resetPID();
        // resetProfile();
        // sendOKFrame();
    // }
    // else if(startsWith(cmdCstr, "ref ")) {
    //     const char* argStart = cmdCstr + 4;
        
    //     float newRef = (float) strtod(argStart, nullptr); //no good way to check parsing, just have to assume a valid value was given
    //     setControlReference(newRef);
    //     resetPID();
    //     resetProfile();
        
    //     if(abs(newRef) > 1 && getControlMode() == CONTROL_MODE_DUTY_CYCLE) {
    //         sendBadFrame("Control reference is beyond range for control mode DUTY_CYCLE", SEVERITY_WARNING);
    //     }
    //     sendOKFrame();
    // }
    else if(startsWithP(commandCstr, F("setSlot "))) {
        SlotConfig* slot = nullptr;
        uint8_t slotNum = static_cast<uint8_t>(NULL);
        if(parseSlotConfigFromCommandArgs(command->c_str() + 8, &slot, &slotNum)) {
            *instructions = ReceivedCommand {
                NO_CHANGE,
                nullptr,
                slot,
                slotNum,
                static_cast<uint8_t>(NULL)
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
    else {
        size_t len = strlen_P((const char*) F("Unknown command ''")) + strlen(commandCstr) + 1;
        char* msg = static_cast<char*>(malloc(len));
        snprintf_P(msg, len, (const char*) F("Unknown command '%s'"), commandCstr);
        
        MessageFrame frame = {SEVERITY_ERROR, msg};
        sendMessageFrame(&frame);
        free(msg);
        
        return false;
    }
}
