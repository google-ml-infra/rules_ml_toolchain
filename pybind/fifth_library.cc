#include "fifth_library.h"
#include "second_library.h"

class FifthClass {
 public:
  FifthClass() {
    second_global++;
  }
};

int fifth_func() {
  return second_global;
}

static FifthClass fifth_var;