#include "controlSlot.hpp"
#include "util.hpp"

bool parseSlotConfigFromCommandArgs(char const * const commandArgs, SlotConfig** const slotOut, uint8_t* const slotNumOut) {
    uint8_t slotNum;
    char* arg2Start;
    if(!parseUInt(commandArgs, &slotNum, &arg2Start)) {
        const MessageFrameP msg =  {SEVERITY_ERROR, F("Malformed SlotConfig, failed to parse arg1 as a uint8_t")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    if(slotNum >= 6) {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed SlotConfig, slotNum must be in range [0, 5]")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    
    if(*arg2Start == '\0') {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed SlotConfig, too few arguments")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    double kP;
    char* arg3Start;
    if(!parseDouble(arg2Start, &kP, &arg3Start)) {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed SlotConfig, failed to parse arg2 as a double")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    
    if(*arg3Start == '\0') {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed SlotConfig, too few arguments")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    double kI;
    char* arg4Start;
    if(!parseDouble(arg3Start, &kI, &arg4Start)) {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed SlotConfig, failed to parse arg3 as a double")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    
    if(*arg4Start == '\0') {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed SlotConfig, too few arguments")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    double kD;
    char* arg5Start;
    if(!parseDouble(arg4Start, &kD, &arg5Start)) {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed SlotConfig, failed to parse arg4 as a double")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    
    if(*arg5Start == '\0') {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed SlotConfig, too few arguments")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    double kS;
    char* arg6Start;
    if(!parseDouble(arg5Start, &kS, &arg6Start)) {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed SlotConfig, failed to parse arg5 as a double")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    
    if(*arg6Start == '\0') {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed SlotConfig, too few arguments")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    uint8_t kSMode;
    char* arg7Start;
    if(!parseUInt(arg6Start, &kSMode, &arg7Start)) {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed SlotConfig, failed to parse arg6 as a uint8_t")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    
    if(*arg7Start == '\0') {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed SlotConfig, too few arguments")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    double vMax;
    char* arg8Start;
    if(!parseDouble(arg7Start, &vMax, &arg8Start)) {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed SlotConfig, failed to parse arg7 as a double")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    
    if(*arg8Start == '\0') {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed SlotConfig, too few arguments")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    double aStart;
    char* arg9Start;
    if(!parseDouble(arg8Start, &aStart, &arg9Start)) {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed SlotConfig, failed to parse arg8 as a double")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    
    if(*arg9Start == '\0') {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed SlotConfig, too few arguments")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    double aEnd;
    char* arg10Start;
    if(!parseDouble(arg9Start, &aEnd, &arg10Start)) {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed SlotConfig, failed to parse arg9 as a double")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    
    if(*arg10Start != '\0') {
        const MessageFrameP msg = {SEVERITY_ERROR, F("Malformed SlotConfig, too many arguments")};
        sendMessageFrameP(&msg);
        
        return false;
    }
    
    *slotOut = new SlotConfig {kP, kI, kD, kS, kSMode, vMax, aStart, aEnd};
    *slotNumOut = slotNum;
    return true;
}
