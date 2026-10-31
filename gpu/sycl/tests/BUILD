# Copyright 2025 Google LLC
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

load("@rules_cc//cc:defs.bzl", "cc_test")

load(
    "@local_config_sycl//sycl:build_defs.bzl",
    "sycl_library",
)

sycl_library(
    name = "vector_sycl",
    srcs = ["vector_sycl.cc"],
    hdrs = ["vector_sycl.h"],
    tags = [
        "gpu",
        "oneapi-only",
    ],
)

cc_test(
    name = "vector_sycl_test",
    srcs = [
        "vector_sycl_test.cc",
    ],
    tags = [
        "gpu",
        "oneapi-only",
    ],
    deps = [
        ":vector_sycl",
        "@gtest//:gtest_main",
    ],
)

#############################################
# Tests Suite
test_suite(
    name = "all",
    tests = [
        ":vector_sycl_test",
    ],
)
