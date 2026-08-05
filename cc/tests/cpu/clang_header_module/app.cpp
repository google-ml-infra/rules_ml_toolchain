#if !__has_feature(modules)
#error "Clang header modules are NOT enabled!"
#endif

//#include "math_utils.h"
#include "math_utils.h"

#include <iostream>

int main() {
    std::cout << "34 + 21 = " << add(34, 21) << std::endl;
    //std::cout << "floor(8.3) = " << floor2(8.3) << std::endl;
    return 0;
}