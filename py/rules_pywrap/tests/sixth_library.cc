//
// Created by yuriit on 3/13/26.
//

#include "sixth_library.h"
#include "second_library.h"

class SixthClass {
    public:
        SixthClass() {
            second_global++;
        }
};

int sixth_func() {
    return second_global;
}

static SixthClass sixth_var;    // TODO: original name was fifth_var