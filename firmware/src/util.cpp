#include "util.hpp"

bool startsWith(const char* str, const char* prefix) {
    return strncmp(prefix, str, strlen(prefix)) == 0;
}
int sign(float val) {
    return val == 0 ? 0 : (val < 0 ? -1 : 1);
}
