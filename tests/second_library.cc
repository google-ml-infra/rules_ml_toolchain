#include "second_library.h"

int second_global = 0;

static int my_pybind_global = 0;

int second_func(int x) {
  return x + my_pybind_global++;
}

int second_global_func() {
  return second_global;
}