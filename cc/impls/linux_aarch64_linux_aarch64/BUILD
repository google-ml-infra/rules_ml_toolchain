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

# ==============================================================================
# Tools: Linux aarch64, Sysroot: Linux aarch64
# ==============================================================================

load("//third_party/rules_cc_toolchain:toolchain_config.bzl", "cc_toolchain_config")
load("//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl", "cc_toolchain_import")
load("//third_party/rules_cc_toolchain/features:features.bzl", "cc_toolchain_import_feature")

package(
    default_visibility = [
        "//cc/impls/cpu:__pkg__",
    ],
)

filegroup(
    name = "wrappers",
    srcs = [
        "//cc/impls/linux_aarch64_linux_aarch64/wrappers:all",
    ],
    visibility = ["//visibility:public"],
)

alias(
    name = "startup_libs",
    actual = "@sysroot_linux_aarch64//:startup_libs",
    visibility = ["//visibility:public"],
)

cc_toolchain_import_feature(
    name = "startup_libs_feature",
    enabled = True,
    toolchain_import = ":startup_libs",
)

# buildifier: leave-alone
cc_toolchain_import(
    name = "imports",
    deps = [
        "@sysroot_linux_aarch64//:includes_c",
        "@llvm_linux_aarch64//:includes",
        "@sysroot_linux_aarch64//:includes_system",
        "@sysroot_linux_aarch64//:syslibs",
        "@sysroot_linux_aarch64//:openmp",
    ],
    visibility = ["//visibility:public"],
)

cc_toolchain_import_feature(
    name = "imports_feature",
    enabled = True,
    toolchain_import = ":imports",
)

# buildifier: leave-alone
filegroup(
    name = "all",
    srcs = [
        ":imports",
        ":wrappers",
        ":startup_libs",
        "@llvm_linux_aarch64//:all",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "compiler",
    srcs = [
        ":imports",
        ":wrappers",
        "@llvm_linux_aarch64//:clang",
        "@llvm_linux_aarch64//:clang++",
        "@llvm_linux_aarch64//:distro_libs",
        "@llvm_linux_aarch64//:asan_ignorelist",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "linker",
    srcs = [
        ":compiler",
        ":wrappers",
        "@llvm_linux_aarch64//:ld",
        "@sysroot_linux_aarch64//:startup_libs",
        "@llvm_linux_aarch64//:distro_libs",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "ar",
    srcs = [
        ":wrappers",
        "@llvm_linux_aarch64//:ar",
        "@llvm_linux_aarch64//:distro_libs",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "objcopy",
    srcs = [
        ":wrappers",
        "@llvm_linux_aarch64//:objcopy",
        "@llvm_linux_aarch64//:distro_libs",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "strip",
    srcs = [
        ":wrappers",
        "@llvm_linux_aarch64//:strip",
        "@llvm_linux_aarch64//:distro_libs",
    ],
)

cc_toolchain_config(
    name = "config",
    archiver = "@llvm_linux_aarch64//:ar",
    c_compiler = "@llvm_linux_aarch64//:clang",
    cc_compiler = "@llvm_linux_aarch64//:clang++",
    compiler_features = [
        # Hermetic libraries feature required before import.
        "//third_party/rules_cc_toolchain/features:hermetic_libraries",
        ":imports_feature",

        # Toolchain configuration
        "//third_party/rules_cc_toolchain/features:warnings",
        "//third_party/rules_cc_toolchain/features:errors",
        "//third_party/rules_cc_toolchain/features:reproducible",
        "//third_party/rules_cc_toolchain/features:language",
        "//third_party/rules_cc_toolchain/features:use_lld",
        "//cc/features:sysroot_linux_aarch64",
        ":startup_libs_feature",
        "//third_party/rules_cc_toolchain/features:coverage",
        #"//cc/features:clang19",    # TODO: Add a selection mechanism based on the Clang version

        # PIC / PIE flags
        "//third_party/rules_cc_toolchain/features:supports_pic",
        "//third_party/rules_cc_toolchain/features:position_independent_code",
        "//third_party/rules_cc_toolchain/features:position_independent_executable",

        # Optimization flags
        "//third_party/rules_cc_toolchain/features:garbage_collect_symbols",
        "//cc/features:constants_merge",
        "//cc/features:asserts_disable",
        "//third_party/rules_cc_toolchain/features:dbg",
        "//third_party/rules_cc_toolchain/features:opt",
        "//cc/features:detect_issues",
        "//cc/features:detect_issues_ext",

        # C++ standard configuration
        "//third_party/rules_cc_toolchain/features:c++11",
        "//third_party/rules_cc_toolchain/features:c++14",
        "//third_party/rules_cc_toolchain/features:c++17",

        #
        "//cc/features:allow_shlib_undefined",
        "//cc/features:supports_dynamic_linker",
        "//cc/features:supports_start_end_lib_feature",
    ],
    linker = "@llvm_linux_aarch64//:ld",
    strip_tool = "@llvm_linux_aarch64//:strip",
    target_cpu = "aarch64",
    target_system_name = "local",
)

cc_toolchain(
    name = "toolchain",
    all_files = ":all",
    ar_files = ":ar",
    compiler_files = ":compiler",
    dwp_files = ":all",
    linker_files = ":linker",
    objcopy_files = ":objcopy",
    strip_files = ":strip",
    supports_param_files = 1,
    toolchain_config = ":config",
    toolchain_identifier = "toolchain_id_linux_aarch64_linux_aarch64",
)
