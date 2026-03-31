# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load("//py/rules_pywrap:pywrap.default.bzl", "pybind_extension")
load("@rules_python//python:py_library.bzl", "py_library")

pybind_extension(
    name = "nested_pybind",
    srcs = ["nested_pybind.cc"],
    common_lib_packages = [
        "",
        "pywrap_external/python",  # non-existent package to test that its Ok
        "py/tests/pybind",
        "py/tests/pybind_external",
        "py/tests/pywrap_external",
    ],
#    visibility = ["//visibility:public"],
    deps = [
        "//py/tests/pybind:fifth_library",
        "@pybind11",
    ],
    local_defines = ["TARGET_NAME=nested_pybind"],
)

py_library(
    name = "relative_import_lib",
    srcs = ["relative_import_lib.py"],
    deps = [
        ":nested_pybind",
    ],
    visibility = ["//visibility:public"]
)

pybind_extension(
    name = "nested_wrapped_pybind",
    srcs = ["nested_pybind.cc"],
    common_lib_packages = [
        "",
        "py/tests/pybind",
    ],
    deps = [
        "//py/tests/pybind:fifth_library",
        "@pybind11",
    ],
    wrap_py_init = True,
    local_defines = ["TARGET_NAME=nested_wrapped_pybind"],
)

py_library(
    name = "relative_wrapped_import_lib",
    srcs = ["relative_wrapped_import_lib.py"],
    deps = [
        ":nested_wrapped_pybind",
    ],
    visibility = ["//visibility:public"]
)