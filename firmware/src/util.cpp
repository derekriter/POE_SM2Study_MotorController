#include "util.hpp"

#include <errno.h>

bool startsWith(char const * const str, char const * const prefix) {
    return strncmp(prefix, str, strlen(prefix)) == 0;
}
bool startsWithP(char const * const str, __FlashStringHelper const * const prefixP) {
    return strncmp_P(str, (char const * const) prefixP, strlen_P((char const * const) prefixP)) == 0;
}
int sign(float val) {
    return val == 0 ? 0 : (val < 0 ? -1 : 1);
}
bool parseDouble(char const * const str, double* const out, char** const end) {
    char* parsedEnd;
    double parsed = strtod(str, &parsedEnd);
    
    //https://forum.arduino.cc/t/how-to-detect-conversion-error-in-strtod/42882/6
    if(parsedEnd == str) return false;
    
    *out = parsed;
    *end = parsedEnd;
    return true;
}
bool parseUInt(char const * const str, uint8_t* const out, char** const end) {
    char* parsedEnd;
    uint8_t parsed = (uint8_t) strtoul(str, &parsedEnd, 10);
    
    if(parsedEnd == str) return false;
    
    *out = parsed;
    *end = parsedEnd;
    return true;
}
