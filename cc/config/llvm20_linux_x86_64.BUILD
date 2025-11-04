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
    "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl",
    "cc_toolchain_import",
)

exports_files(glob(["bin/*"]))

CLANG_VERSION = "20"

filegroup(
    name = "all",
    srcs = glob(["**/*"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "clang",
    srcs = [
        "bin/clang",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "clang++",
    srcs = [
        "bin/clang++",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "ld",
    srcs = [
        "bin/ld.lld",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "ar",
    srcs = ["bin/llvm-ar"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "ar_darwin",
    srcs = ["bin/llvm-libtool-darwin"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "objcopy",
    srcs = ["bin/llvm-objcopy"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "strip",
    srcs = ["bin/llvm-strip"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "install_name_tool_darwin",
    srcs = ["bin/llvm-install-name-tool"],
    visibility = ["//visibility:public"],
)

# Stub for LLVM 18 Linux x86_64, leave it for backward compatibility
filegroup(
    name = "distro_libs",
    srcs = [],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "asan_ignorelist",
    srcs = [
        "lib/clang/{clang_version}/share/asan_ignorelist.txt".format(clang_version = CLANG_VERSION),
    ],
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "includes",
    hdrs = glob([
        "lib/clang/{clang_version}/include/**".format(clang_version = CLANG_VERSION),
        "lib/clang/{clang_version}/include/cuda_wrappers/**".format(clang_version = CLANG_VERSION),
    ]),
    includes = [
        "lib/clang/{clang_version}".format(clang_version = CLANG_VERSION),
        "lib/clang/{clang_version}/include".format(clang_version = CLANG_VERSION),
    ],
    target_compatible_with = select({
        "@platforms//os:linux": [],
        "@platforms//os:macos": [],
    }),
    visibility = ["//visibility:public"],
)

# This library is needed for LiteRT because it uses a compiler-specific
# built-in functions, and these functions are not provided by GCC 8.4.
cc_toolchain_import(
    name = "libclang_rt",
    static_library = "lib/clang/{clang_version}/lib/x86_64-unknown-linux-gnu/libclang_rt.builtins.a".format(clang_version = CLANG_VERSION),
    target_compatible_with = select({
        "@platforms//os:linux": [],
        "@platforms//os:macos": [],
    }),
    visibility = ["//visibility:public"],
)

# Use when build CUDA by Clang (NVCC doesn't need it)
cc_library(
    name = "cuda_wrappers_headers",
    includes = [
        "lib/clang/{clang_version}/include/cuda_wrappers".format(clang_version = CLANG_VERSION),
    ],
    visibility = ["//visibility:public"],
)
