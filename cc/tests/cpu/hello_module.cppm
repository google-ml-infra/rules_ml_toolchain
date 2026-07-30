module;

#include <iostream>

export module hello;

export void say_hello() {
    std::cout << "Hello World from C++ Modules!\n";
}