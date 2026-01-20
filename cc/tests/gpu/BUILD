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
# Hermetic CC Toolchain Ultimate Test

# Execution platform rules
cc_binary(
    name = "protogen",
    srcs = ["protogen.cc"],
    linkshared = True,
    deps = ["@pybind11"],
)

genrule(
    name = "protogen_so",
    srcs = [":protogen"],
    outs = ["protogen.so"],
    cmd = "cp $(location :protogen) $@",
)

py_binary(
    name = "protogen_tool",
    srcs = ["protogen_tool.py"],
    #args = [
    #    "-f /tmp/my.proto",
    #],
    data = [":protogen.so"],
)

genrule(
    name = "my_proto",
    outs = [
        "my.proto",
    ],
    cmd = "$(location :protogen_tool) -f $@",
    tools = [":protogen_tool"],
)

proto_library(
    name = "my_proto_library",
    srcs = [":my_proto"],
)

# Target platform rules
cc_proto_library(
    name = "my_proto_library_cc",
    deps = [":my_proto_library"],
)

cc_binary(
    name = "protoclient",
    srcs = ["protoclient.cc"],
    linkshared = True,
    linkstatic = True,
    deps = [
        ":my_proto_library_cc",
        "@com_google_protobuf//:protobuf",
        "@pybind11",
    ],
    features = ["asan_runtime_closure_feature"],
)

genrule(
    name = "protoclient_so",
    srcs = [":protoclient"],
    outs = ["protoclient.so"],
    cmd = "cp $(location :protoclient) $@",
)

py_binary(
    name = "protoclient_tool",
    srcs = ["protoclient_tool.py"],
    data = [":protoclient.so"],
    deps = [],
)

py_test(
    name = "protoclient_tool_test",
    srcs = ["protoclient_tool_test.py"],
    data = [":protoclient.so"],
    deps = [],
)

#############################################
# Tests Suite
test_suite(
    name = "all",
    tests = [
        ":protoclient_tool_test",
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
