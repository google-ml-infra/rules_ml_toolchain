#include "second_library.h"

class FourthClass {
 public:
  FourthClass() {
    second_global++;
  }
};

static FourthClass fourth_var;