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

load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@rules_cc//cc:defs.bzl", "cc_test")
load("//cc/rocm:rocm_library.bzl", "rocm_library")

rocm_library(
    name = "vector_hip",
    srcs = ["vector_hip.hip.cc"],
    hdrs = ["vector_hip.hip.h"],
    tags = ["rocm-only"],
    deps = ["@config_rocm_hipcc//rocm:hip_runtime"],
)

cc_test(
    name = "vector_hip_test",
    srcs = [
        "vector_hip_test.cc",
    ],
    tags = [
        "rocm-only",
        "gpu",
        "manual",  # Requires actual GPU hardware - run manually only
    ],
    deps = [
        ":vector_hip",
        "@config_rocm_hipcc//rocm:hip_runtime",
        "@gtest//:gtest_main",
    ],
)

build_test(
    name = "vector_hip_build_test",
    targets = [":vector_hip_test"],
)

test_suite(
    name = "all",
    tests = [
        ":vector_hip_build_test",  # CI runs build test only
    ],
)
