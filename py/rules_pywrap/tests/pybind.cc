#include "first_library.h"
#include "second_library.h"
#include "third_library.h"
#include "pybind11/pybind11.h"
#include "fifth_library.h"

int sub_sub_func(int x) {
  return x << 1;
}

PYBIND11_MODULE(TARGET_NAME, m) {
  fifth_func(); // needed to  make sure the dynamic library is loaded on Windows
  m.doc() = "pybind11 example plugin";
  m.def("first_func", &first_func, "The first function");
  m.def("second_func", &second_func, "The second function");
  m.def("third_func", &third_func, "The third function");
  m.def("second_global_func", &second_global_func, "The second_global function");
  m.attr("_EXTRA_SYMBOL") = pybind11::int_(123);

  auto subM = m.def_submodule("sub", "submodule");
  subM.def("second_func", &second_func, "");
  auto subSubM = subM.def_submodule("_sub_private", "sub submodule");
  subSubM.def("sub_sub_func", &sub_sub_func, "");
  subSubM.def("_sub_private_private_func", &sub_sub_func, "private sub func");
}