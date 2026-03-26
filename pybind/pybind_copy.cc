#include "first_library.h"
#include "second_library.h"
#include "third_library.h"
#include "pybind11/pybind11.h"

PYBIND11_MODULE(TARGET_NAME, m) {
  m.doc() = "pybind11 example plugin";
  m.def("first_func", &first_func, "The first function");
  m.def("second_func", &second_func, "The second function");
  m.def("third_func", &third_func, "The third function");
  m.def("second_global_func", &second_global_func, "The second_global function");
  m.attr("_EXTRA_SYMBOL") = pybind11::int_(123);
}