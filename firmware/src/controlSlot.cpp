#include "controlSlot.hpp"
#include "util.hpp"

bool parseSlotConfigFromCommandArgs(const char* commandArgs, SlotConfig** slotOut, uint8_t* slotNumOut) {
    uint8_t slotNum;
    char* arg2Start;
    if(!parseUInt(commandArgs, &slotNum, &arg2Start)) {
        MessageFrame msg =  {SEVERITY_ERROR, "Malformed SlotConfig, failed to parse arg1 as a uint8_t"};
        sendMessageFrame(&msg);
        
        return false;
    }
    if(slotNum >= 6) {
        MessageFrame msg = {SEVERITY_ERROR, "Malformed SlotConfig, slotNum must be in range [0, 5]"};
        sendMessageFrame(&msg);
        
        return false;
    }
    
    if(*arg2Start == '\0') {
        MessageFrame msg = {SEVERITY_ERROR, "Malformed SlotConfig, too few arguments"};
        sendMessageFrame(&msg);
        
        return false;
    }
    double kP;
    char* arg3Start;
    if(!parseDouble(arg2Start, &kP, &arg3Start)) {
        MessageFrame msg = {SEVERITY_ERROR, "Malformed SlotConfig, failed to parse arg2 as a double"};
        sendMessageFrame(&msg);
        
        return false;
    }
    
    if(*arg3Start == '\0') {
        MessageFrame msg = {SEVERITY_ERROR, "Malformed SlotConfig, too few arguments"};
        sendMessageFrame(&msg);
        
        return false;
    }
    double kI;
    char* arg4Start;
    if(!parseDouble(arg3Start, &kI, &arg4Start)) {
        MessageFrame msg = {SEVERITY_ERROR, "Malformed SlotConfig, failed to parse arg3 as a double"};
        sendMessageFrame(&msg);
        
        return false;
    }
    
    if(*arg4Start == '\0') {
        MessageFrame msg = {SEVERITY_ERROR, "Malformed SlotConfig, too few arguments"};
        sendMessageFrame(&msg);
        
        return false;
    }
    double kD;
    char* arg5Start;
    if(!parseDouble(arg4Start, &kD, &arg5Start)) {
        MessageFrame msg = {SEVERITY_ERROR, "Malformed SlotConfig, failed to parse arg4 as a double"};
        sendMessageFrame(&msg);
        
        return false;
    }
    
    if(*arg5Start == '\0') {
        MessageFrame msg = {SEVERITY_ERROR, "Malformed SlotConfig, too few arguments"};
        sendMessageFrame(&msg);
        
        return false;
    }
    double kS;
    char* arg6Start;
    if(!parseDouble(arg5Start, &kS, &arg6Start)) {
        MessageFrame msg = {SEVERITY_ERROR, "Malformed SlotConfig, failed to parse arg5 as a double"};
        sendMessageFrame(&msg);
        
        return false;
    }
    
    if(*arg6Start == '\0') {
        MessageFrame msg = {SEVERITY_ERROR, "Malformed SlotConfig, too few arguments"};
        sendMessageFrame(&msg);
        
        return false;
    }
    uint8_t kSMode;
    char* arg7Start;
    if(!parseUInt(arg6Start, &kSMode, &arg7Start)) {
        MessageFrame msg = {SEVERITY_ERROR, "Malformed SlotConfig, failed to parse arg6 as a uint8_t"};
        sendMessageFrame(&msg);
        
        return false;
    }
    
    if(*arg7Start == '\0') {
        MessageFrame msg = {SEVERITY_ERROR, "Malformed SlotConfig, too few arguments"};
        sendMessageFrame(&msg);
        
        return false;
    }
    double vMax;
    char* arg8Start;
    if(!parseDouble(arg7Start, &vMax, &arg8Start)) {
        MessageFrame msg = {SEVERITY_ERROR, "Malformed SlotConfig, failed to parse arg7 as a double"};
        sendMessageFrame(&msg);
        
        return false;
    }
    
    if(*arg8Start == '\0') {
        MessageFrame msg = {SEVERITY_ERROR, "Malformed SlotConfig, too few arguments"};
        sendMessageFrame(&msg);
        
        return false;
    }
    double aStart;
    char* arg9Start;
    if(!parseDouble(arg8Start, &aStart, &arg9Start)) {
        MessageFrame msg = {SEVERITY_ERROR, "Malformed SlotConfig, failed to parse arg8 as a double"};
        sendMessageFrame(&msg);
        
        return false;
    }
    
    if(*arg9Start == '\0') {
        MessageFrame msg = {SEVERITY_ERROR, "Malformed SlotConfig, too few arguments"};
        sendMessageFrame(&msg);
        
        return false;
    }
    double aEnd;
    char* arg10Start;
    if(!parseDouble(arg9Start, &aEnd, &arg10Start)) {
        MessageFrame msg = {SEVERITY_ERROR, "Malformed SlotConfig, failed to parse arg9 as a double"};
        sendMessageFrame(&msg);
        
        return false;
    }
    
    if(*arg10Start != '\0') {
        MessageFrame msg = {SEVERITY_ERROR, "Malformed SlotConfig, too many arguments"};
        sendMessageFrame(&msg);
        
        return false;
    }
    
    *slotOut = new SlotConfig {kP, kI, kD, kS, kSMode, vMax, aStart, aEnd};
    *slotNumOut = slotNum;
    return true;
}
