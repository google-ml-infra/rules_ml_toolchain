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
# ==============================================================================

load("@rules_cc//cc:defs.bzl", "cc_library", "cc_test")
load(
    "//fortran:defs.bzl",
    "fortran_binary",
    "fortran_library",
    "fortran_test",
)

#############################################
# Pure Fortran binary and test
fortran_binary(
    name = "hello_world",
    srcs = ["hello_world.f90"],
)

fortran_test(
    name = "hello_world_test",
    srcs = ["hello_world_test.f90"],
)

#############################################
# Fortran modules & transitive libraries
fortran_library(
    name = "math_mod",
    srcs = ["math_mod.f90"],
    hdrs = ["math_mod.h"],
)

fortran_library(
    name = "linalg_mod",
    srcs = ["linalg_mod.f90"],
    deps = [":math_mod"],
)

fortran_test(
    name = "module_test",
    srcs = ["module_test.f90"],
    deps = [":linalg_mod"],
)

#############################################
# Preprocessed Fortran (.F90)
fortran_test(
    name = "preprocessed_test",
    srcs = ["preprocessed_test.F90"],
    defines = ["EXPECTED_ANSWER=42"],
    deps = [":math_mod"],
)

#############################################
# C++ / Fortran Interoperability
cc_library(
    name = "c_interop_helper",
    srcs = ["c_interop_helper.cc"],
    hdrs = ["c_interop_helper.h"],
)

fortran_test(
    name = "fortran_calls_c_test",
    srcs = ["fortran_calls_c_test.f90"],
    deps = [":c_interop_helper"],
)

cc_test(
    name = "cc_calls_fortran_test",
    srcs = ["cc_calls_fortran_test.cc"],
    deps = [
        ":math_mod",
        "@gtest//:gtest_main",
    ],
)

#############################################
# Tests Suite
test_suite(
    name = "all",
    tests = [
        ":cc_calls_fortran_test",
        ":fortran_calls_c_test",
        ":hello_world_test",
        ":module_test",
        ":preprocessed_test",
    ],
)
