#include "util.hpp"

#include <errno.h>

bool startsWith(const char* str, const char* prefix) {
    return strncmp(prefix, str, strlen(prefix)) == 0;
}
int sign(float val) {
    return val == 0 ? 0 : (val < 0 ? -1 : 1);
}
bool parseDouble(const char* str, double* out, char** end) {
    char* parsedEnd;
    double parsed = strtod(str, &parsedEnd);
    
    //https://forum.arduino.cc/t/how-to-detect-conversion-error-in-strtod/42882/6
    if(parsedEnd == str) return false;
    
    *out = parsed;
    *end = parsedEnd;
    return true;
}
