#include "serial.hpp"
#include "control.hpp"
#include "util.hpp"
#include "controlMode.hpp"

void sendDataFrame(double avgTPS, float avgErr) {
    Serial.print("{\"ty\":\"data\",\"py\":{");
    
    Serial.print("\"en\":");
    Serial.print(getMotorEnabled() ? "true" : "false");
    
    Serial.print(",\"sv\":");
    Serial.print(getSourceVoltage(), 4);
    
    Serial.print(",\"cm\":");
    Serial.print(getControlMode()->getID());
    
    Serial.print(",\"pt\":");
    Serial.print(getEncoderTicks());
    
    Serial.print(",\"pr\":");
    Serial.print(getEncoderRotations(), 4);
    
    Serial.print(",\"vt\":");
    Serial.print(avgTPS, 4);
    
    Serial.print(",\"vr\":");
    Serial.print(avgTPS / ENCODER_TICKS_PER_ROTATION * 60, 4);
    
    Serial.print(",\"ms\":");
    Serial.print(millis());
    
    Serial.print(",\"co\":");
    Serial.print(getCommandedOutput(), 4);
    
    Serial.print(",\"er\":");
    Serial.print(avgErr, 4);
    
    Serial.println("}}");
}
void sendMessageFrame(const char* msg) {
    Serial.print("{\"ty\":\"msg\",\"py\":\"");
    
    Serial.print(msg);
    
    Serial.println("\"}");
}
void sendOKFrame() {
    Serial.println("{\"ty\":\"ok\"}");
}
void sendBadFrame(const char* msg, uint8_t severity) {
    Serial.print("{\"ty\":\"bad\",\"py\":{");
    
    Serial.print("\"sv\":");
    Serial.print(severity);
    
    Serial.print(",\"msg\":\"");
    Serial.print(msg);
    
    Serial.println("\"}}");
}
bool getIncomingIfAvailable(String* incoming) {
    if(!Serial.available()) return false;
    
    *incoming = Serial.readStringUntil('\0');
    return true;
}
void processCommand(const String* command) {
    const char* cmdCstr = command->c_str();
    
    if(strcmp(cmdCstr, "enable") == 0) {
        setMotorEnabled(true);
        sendOKFrame();
    }
    else if(strcmp(cmdCstr, "disable") == 0) {
        setMotorEnabled(false);
        sendOKFrame();
    }
    else if(startsWith(cmdCstr, "stop ") == 0) {
        StopControlMode control;
        if(StopControlMode::parseFromCommandArgs(cmdCstr + 5, &control)) {
            setControlMode(control);
            sendOKFrame();
        }
    }
    else if(startsWith(cmdCstr, "dutyCycle ") == 0) {
        DutyCycleControlMode control(0);
        if(DutyCycleControlMode::parseFromCommandArgs(cmdCstr + 10, &control)) {
            setControlMode(control);
            sendOKFrame();
        }
    }
    else if(startsWith(cmdCstr, "voltage ") == 0) {
        // setControlMode(CONTROL_MODE_VOLTAGE);
        // sendOKFrame();
    }
    else if(startsWith(cmdCstr, "pidPos ") == 0) {
        // setControlMode(CONTROL_MODE_PID_POSITION);
        // resetPID();
        // sendOKFrame();
    }
    else if(startsWith(cmdCstr, "pidVel ") == 0) {
        // setControlMode(CONTROL_MODE_PID_VELOCITY);
        // resetPID();
        // sendOKFrame();
    }
    else if(startsWith(cmdCstr, "trapPos ") == 0) {
        // setControlMode(CONTROL_MODE_TRAP_POSITION);
        // resetPID();
        // resetProfile();
        // sendOKFrame();
    }
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
        size_t len = strlen("Unknown command ''") + strlen(cmdCstr) + 1;
        char* msg = (char*) malloc(len);
        snprintf(msg, len, "Unknown command '%s'", cmdCstr);
        
        sendBadFrame(msg, SEVERITY_ERROR);
        
        free(msg);
    }
}
