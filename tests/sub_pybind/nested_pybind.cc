#include "pybind11/pybind11.h"
#include "pybind/fifth_library.h"

int nested_pybind_func(int x) {
  return x >> 1;
}

PYBIND11_MODULE(TARGET_NAME, m) {
  fifth_func(); // needed to  make sure the dynamic library is loaded on Windows
  m.def("nested_pybind_func", &nested_pybind_func, "");
}