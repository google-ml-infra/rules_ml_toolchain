//
// Created by yuriit on 3/13/26.
//

#include "sixth_library.h"
#include "pybind11/pybind11.h"

PYBIND11_MODULE(pybind_with_starlark_only, m) {
    m.doc() = "pybind11 example plugin";
    m.def("sixth_func", &sixth_func, "sixth func");
}