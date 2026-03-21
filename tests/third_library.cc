#include "third_library.h"
//#include "second_library.h"

//class ThirdClass {
// public:
//  ThirdClass() {
//    second_global++;
//  }
//};

static int my_pybind_global_copy = 0;

int third_func(int x) {
  return x + my_pybind_global_copy++;
}

//static ThirdClass fifth_var;