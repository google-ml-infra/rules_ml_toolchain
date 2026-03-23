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

static SixthClass fifth_var;