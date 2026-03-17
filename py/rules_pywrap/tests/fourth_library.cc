//
// Created by yuriit on 3/13/26.
//
#include "second_library.h"

class FourthClass {
    public:
        FourthClass() {
            second_global++;
        }
};

static FourthClass fourth_val;
