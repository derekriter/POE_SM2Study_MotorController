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

bool getIncomingIfAvailable(String* incoming) {
    if(!Serial.available()) return false;
    
    *incoming = Serial.readStringUntil('\0');
    return true;
}
bool processCommand(const String* command, ReceivedCommand* instructions) {
    if(command->equals("enable")) {
        *instructions = ReceivedCommand {SET_ENABLE, nullptr};
        
        sendOKFrame();
        return true;
    }
    else if(command->equals("disable")) {
        *instructions = ReceivedCommand {SET_DISABLE, nullptr};
        
        sendOKFrame();
        return true;
    }
    else if(command->equals("stop")) {
        *instructions = ReceivedCommand {NO_CHANGE, new StopControlMode()};
        
        sendOKFrame();
        return true;
    }
    else if(command->startsWith("dutyCycle ")) {
        DutyCycleControlMode* control = nullptr;
        if(DutyCycleControlMode::parseFromCommandArgs(command->c_str() + 10, &control)) {
            *instructions = ReceivedCommand {NO_CHANGE, control};
            
            sendOKFrame();
            return true;
        }
        
        return false;
    }
    // else if(command->startsWith("voltage ")) {
        // setControlMode(CONTROL_MODE_VOLTAGE);
        // sendOKFrame();
    // }
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
    // else if(startsWith(cmdCstr, "kP ")) {
    //     const char* argStart = cmdCstr + 3;
        
    //     float newKP = (float) strtod(argStart, nullptr);
    //     setKP(newKP);
        
    //     sendOKFrame();
    // }
    // else if(startsWith(cmdCstr, "kI ")) {
    //     const char* argStart = cmdCstr + 3;
        
    //     float newKI = (float) strtod(argStart, nullptr);
    //     setKI(newKI);
        
    //     sendOKFrame();
    // }
    // else if(startsWith(cmdCstr, "kD ")) {
    //     const char* argStart = cmdCstr + 3;
        
    //     float newKD = (float) strtod(argStart, nullptr);
    //     setKD(newKD);
        
    //     sendOKFrame();
    // }
    // else if(startsWith(cmdCstr, "kS ")) {
    //     const char* argStart = cmdCstr + 3;
        
    //     float newKS = (float) strtod(argStart, nullptr);
    //     setKS(newKS);
        
    //     sendOKFrame();
    // }
    // else if(startsWith(cmdCstr, "vMax ")) {
    //     const char* argStart = cmdCstr + 5;
        
    //     float newVMax = (float) strtod(argStart, nullptr);
    //     setVMax(newVMax);
        
    //     sendOKFrame();
    // }
    // else if(startsWith(cmdCstr, "aStart ")) {
    //     const char* argStart = cmdCstr + 7;
        
    //     float newAStart = (float) strtod(argStart, nullptr);
    //     setAStart(newAStart);
        
    //     sendOKFrame();
    // }
    // else if(startsWith(cmdCstr, "aEnd ")) {
    //     const char* argStart = cmdCstr + 5;
        
    //     float newAEnd = (float) strtod(argStart, nullptr);
    //     setAEnd(newAEnd);
        
    //     sendOKFrame();
    // }
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
