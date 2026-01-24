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

load(
    "@local_config_cuda//cuda:build_defs.bzl",
    "cuda_cc_test",
    "cuda_default_copts",
    "cuda_library",
)

cc_binary(
    name = "hello_world",
    srcs = [
        "hello_world.cc",
    ],
)

cuda_library(
    name = "vector_cuda",
    srcs = ["vector_cuda.cu.cc"],
    hdrs = ["vector_cuda.cu.h"],
    tags = ["cuda-only"],
)

cuda_cc_test(
    name = "vector_cuda_test",
    srcs = [
        "vector_cuda_test.cc",
    ],
    tags = [
        "cuda-only",
        "gpu",
    ],
    deps = [
        ":vector_cuda",
        "@cuda_cudart//:cudart",
        "@gtest//:gtest_main",
        "@local_config_cuda//cuda:implicit_cuda_headers_dependency",
    ],
)

#############################################
# Tests Suite
test_suite(
    name = "all",
    tests = [
        ":vector_cuda_test",
    ],
)

#cc_binary(
#    name = "vector_cuda_binary",
#    srcs = [
#        "vector_cuda_binary.cc",
#    ],
#    copts = [
#        "-x",
#        "cuda",
#        "-DGOOGLE_CUDA=1",
#        "--no-cuda-include-ptx=all",
#        "--cuda-feature=+ptx83",
#        "--cuda-gpu-arch=sm_50",
#        "--cuda-gpu-arch=sm_60",
#        "--cuda-gpu-arch=sm_70",
#        "--cuda-gpu-arch=sm_80",
#        "--cuda-include-ptx=sm_90",
#        "--cuda-gpu-arch=sm_90",
#        "-Xcuda-fatbinary",
#        "--compress-all",
#    ],
#    tags = [
#        "cuda-only",
#        "gpu",
#    ],
#    deps = [
#        ":vector_cuda",
#        "@cuda_cudart//:cudart",
#        "@local_config_cuda//cuda:implicit_cuda_headers_dependency",
#    ],
#)
