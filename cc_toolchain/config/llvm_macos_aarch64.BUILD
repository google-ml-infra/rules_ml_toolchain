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

CLANG_VERSION = "18"

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
    srcs = ["bin/llvm-libtool-darwin"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "install_name_tool_darwin",
    srcs = ["bin/llvm-install-name-tool"],
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "includes",
    hdrs = glob([
        "lib/clang/*/*.h",
        "lib/clang/*/include/*.h",
        "lib/clang/*/include/**/*.h",
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
