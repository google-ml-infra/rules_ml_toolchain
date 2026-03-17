//
// Created by yuriit on 3/13/26.
//

#include "third_library.h"

static int my_pybind_global_copy = 0;

int third_func(int x) {
    return x + my_pybind_global_copy++;
}
