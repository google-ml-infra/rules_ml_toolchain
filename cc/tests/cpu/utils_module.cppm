module;

#include <string>

export module UtilsModule;

export int add(int a, int b) {
    return a + b;
}

export std::string concat_strings(const std::string &a, const std::string &b) {
    return a + b;
}
