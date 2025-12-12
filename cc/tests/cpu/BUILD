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

load("@pybind11_bazel//:build_defs.bzl", "pybind_extension")
load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library", "cc_proto_library", "cc_test")
load("@rules_proto//proto:defs.bzl", "proto_library")

#############################################
# C
cc_binary(
    name = "hello_world_c",
    srcs = ["hello_world.c"],
)

#############################################
# C++
cc_binary(
    name = "hello_world",
    srcs = ["hello_world.cc"],
)

cc_test(
    name = "hello_world_test",
    srcs = ["hello_world.cc"],
)

#############################################
# Test compiler Builtins
cc_test(
    name = "builtins_test",
    srcs = ["builtins_test.cc"],
    deps = [
        "@gtest//:gtest_main",
    ],
)

#############################################
# C++ library
cc_library(
    name = "echo",
    srcs = ["echo.cc"],
    hdrs = ["echo.h"],
    alwayslink = True,
)

cc_binary(
    name = "echo_dynamic",
    linkshared = True,
    deps = [":echo"],
)

cc_import(
    name = "echo_import",
    hdrs = ["echo.h"],
    shared_library = ":echo_dynamic",
)

cc_binary(
    name = "echoclient",
    srcs = [
        "echoclient.cc",
        ":echo_dynamic",
    ],
    deps = [":echo_import"],
)

cc_test(
    name = "echoclient_test",
    srcs = [
        "echoclient_test.cc",
        ":echo_dynamic",
    ],
    deps = [
        ":echo_import",
        "@gtest//:gtest_main",
    ],
)

#############################################
# C++ and Google Protobuf
proto_library(
    name = "protobuf_hello",
    srcs = ["protobuf_hello.proto"],
    visibility = ["//visibility:public"],
)

cc_proto_library(
    name = "protobuf_hello_lib",
    visibility = ["//visibility:public"],
    deps = [":protobuf_hello"],
)

cc_binary(
    name = "protobuf",
    srcs = ["protobuf.cc"],
    deps = [":protobuf_hello_lib"],
)

cc_test(
    name = "protobuf_test",
    srcs = ["protobuf_test.cc"],
    deps = [
        ":protobuf_hello_lib",
        "@gtest//:gtest_main",
    ],
)

#############################################
# C++ and Abseil
cc_binary(
    name = "absl",
    srcs = ["absl.cc"],
    deps = [
        "@com_google_absl//absl/algorithm:container",
        "@com_google_absl//absl/container:flat_hash_map",
        "@com_google_absl//absl/container:flat_hash_set",
        "@com_google_absl//absl/strings",
    ],
)

cc_test(
    name = "absl_test",
    srcs = ["absl_test.cc"],
    deps = [
        "@com_google_absl//absl/algorithm:container",
        "@com_google_absl//absl/container:flat_hash_map",
        "@com_google_absl//absl/container:flat_hash_set",
        "@com_google_absl//absl/strings",
        "@gtest//:gtest_main",
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
# OpenMP
cc_test(
    name = "openmp_test",
    srcs = ["openmp_test.cc"],
    deps = [
        "//cc/sysroots:openmp",
        "@gtest//:gtest_main",
    ],
    linkopts = [
        "-fopenmp",
    ],
)

#############################################
# Tests Suite
test_suite(
    name = "all",
    tests = [
        ":absl_test",
        ":builtins_test",
        ":echoclient_test",
        ":protobuf_test",
        ":protoclient_tool_test",
        ":openmp_test",
    ],
)
