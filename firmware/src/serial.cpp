#include "serial.hpp"
#include "util.hpp"
#include "controlMode.hpp"

void sendDataFrame(const DataFrame* data) {
    Serial.print("{\"ty\":\"data\",\"py\":{");
    
    Serial.print("\"en\":");
    Serial.print(data->enabled ? "true" : "false");
    
    Serial.print(",\"sv\":");
    Serial.print(data->sourceVoltage, 4);
    
    Serial.print(",\"pr\":");
    Serial.print(data->position, 4);
    
    Serial.print(",\"vr\":");
    Serial.print(data->velocity, 4);
    
    Serial.print(",\"cm\":");
    Serial.print(data->controlModeData);
    
    Serial.print(",\"ms\":");
    Serial.print(data->millis);
    
    Serial.println("}}");
}
void sendMessageFrame(const MessageFrame* msg) {
    Serial.print("{\"ty\":\"msg\",\"py\":{");
    
    Serial.print("\"sv\":");
    Serial.print(msg->severity);
    
    Serial.print(",\"msg\":\"");
    Serial.print(msg->message);
    
    Serial.println("\"}}");
}
void sendOKFrame() {
    Serial.println("{\"ty\":\"ok\"}");
}
void sendSlotFrame(const SlotFrame* slot) {
    Serial.print("{\"ty\":\"slot\",\"py\":{");
    
    Serial.print("\"sn\":");
    Serial.print(slot->slotNum);
    
    Serial.print(",\"p\":");
    Serial.print(slot->kP);
    
    Serial.print(",\"i\":");
    Serial.print(slot->kI);
    
    Serial.print(",\"d\":");
    Serial.print(slot->kD);
    
    Serial.print(",\"s\":");
    Serial.print(slot->kS);
    
    Serial.print(",\"sm\":");
    Serial.print(slot->kSMode);
    
    Serial.print(",\"v\":");
    Serial.print(slot->vMax);
    
    Serial.print(",\"as\":");
    Serial.print(slot->aStart);
    
    Serial.print(",\"ae\":");
    Serial.print(slot->aEnd);
    
    Serial.print("}}");
}

bool getIncomingIfAvailable(String* incoming) {
    if(!Serial.available()) return false;
    
    *incoming = Serial.readStringUntil('\0');
    return true;
}
bool processCommand(const String* command, ReceivedCommand* instructions) {
    if(command->equals("enable")) {
        *instructions = ReceivedCommand {
            SET_ENABLE,
            nullptr,
            nullptr,
            (uint8_t) NULL,
            (uint8_t) NULL
        };
        
        sendOKFrame();
        return true;
    }
    else if(command->equals("disable")) {
        *instructions = ReceivedCommand {
            SET_DISABLE,
            nullptr,
            nullptr,
            (uint8_t) NULL,
            (uint8_t) NULL
        };
        
        sendOKFrame();
        return true;
    }
    else if(command->equals("stop")) {
        *instructions = ReceivedCommand {
            NO_CHANGE,
            new StopControlMode(),
            nullptr, (uint8_t) NULL,
            (uint8_t) NULL
        };
        
        sendOKFrame();
        return true;
    }
    else if(command->startsWith("dutyCycle ")) {
        DutyCycleControlMode* control = nullptr;
        if(DutyCycleControlMode::parseFromCommandArgs(command->c_str() + 10, &control)) {
            *instructions = ReceivedCommand {
                NO_CHANGE,
                control,
                nullptr,
                (uint8_t) NULL,
                (uint8_t) NULL
            };
            
            sendOKFrame();
            return true;
        }
        
        return false;
    }
    else if(command->startsWith("voltage ")) {
        VoltageControlMode* control = nullptr;
        if(VoltageControlMode::parseFromCommandArgs(command->c_str() + 8, &control)) {
            *instructions = ReceivedCommand {
                NO_CHANGE,
                control,
                nullptr,
                (uint8_t) NULL,
                (uint8_t) NULL
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
    else if(command->startsWith("setSlot ")) {
        SlotConfig* slot = nullptr;
        uint8_t slotNum = (uint8_t) NULL;
        if(parseSlotConfigFromCommandArgs(command->c_str() + 8, &slot, &slotNum)) {
            *instructions = ReceivedCommand {
                NO_CHANGE,
                nullptr,
                slot,
                slotNum,
                (uint8_t) NULL
            };
            
            sendOKFrame();
            return true;
        }
        
        return false;
    }
    else if(command->startsWith("getSlot ")) {
        uint8_t slotNum;
        char* arg2Start;
        if(!parseUInt(command->c_str() + 8, &slotNum, &arg2Start)) {
            MessageFrame msg =  {SEVERITY_ERROR, "Malformed getSlot, failed to parse arg1 as a uint8_t"};
            sendMessageFrame(&msg);
            
            return false;
        }
        if(slotNum >= 6) {
            MessageFrame msg = {SEVERITY_ERROR, "Malformed getSlot, slotNum must be in range [0, 5]"};
            sendMessageFrame(&msg);
            
            return false;
        }
        
        if(*arg2Start != '\0') {
            MessageFrame msg = {SEVERITY_ERROR, "Malformed getSlot, too many arguments"};
            sendMessageFrame(&msg);
            
            return false;
        }
        
        *instructions = ReceivedCommand {
            NO_CHANGE,
            nullptr,
            nullptr,
            (uint8_t) NULL,
            slotNum
        };
        
        sendOKFrame();
        return true;
    }
    else {
        size_t len = strlen("Unknown command ''") + command->length() + 1;
        char* msg = (char*) malloc(len);
        snprintf(msg, len, "Unknown command '%s'", command->c_str());
        
        MessageFrame frame = {SEVERITY_ERROR, msg};
        sendMessageFrame(&frame);
        free(msg);
        
        return false;
    }
}
