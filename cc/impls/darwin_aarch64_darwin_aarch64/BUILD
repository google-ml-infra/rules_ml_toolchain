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
# Tools: macOS aarch64, Sysroot: macOS aarch64
# ==============================================================================

load("@rules_cc//cc:defs.bzl", "cc_toolchain")
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
        "//cc/impls/darwin_aarch64_darwin_aarch64/wrappers:all",
    ],
    visibility = ["//visibility:public"],
)

# buildifier: leave-alone
cc_toolchain_import(
    name = "imports",
    deps = [
        "@sysroot_darwin_aarch64//:includes_c",
        "@llvm_darwin_aarch64//:includes",
        "@sysroot_darwin_aarch64//:includes_system",
        "@sysroot_darwin_aarch64//:glibc",
        "@sysroot_darwin_aarch64//:pthread",
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
        "@llvm_darwin_aarch64//:all",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "compiler",
    srcs = [
        ":all",
        ":wrappers",
        "@llvm_darwin_aarch64//:clang",
        "@llvm_darwin_aarch64//:clang++",
        "@llvm_darwin_aarch64//:asan_ignorelist",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "linker",
    srcs = [
        ":compiler",
        ":wrappers",
        "@llvm_darwin_aarch64//:ld",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "ar",
    srcs = [
        ":wrappers",
        "@llvm_darwin_aarch64//:ar",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "objcopy",
    srcs = [
        ":wrappers",
        "@llvm_darwin_aarch64//:objcopy",
        "@llvm_darwin_aarch64//:distro_libs",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "strip",
    srcs = [
        ":wrappers",
        "@llvm_darwin_aarch64//:strip",
        "@llvm_darwin_aarch64//:distro_libs",
    ],
)

cc_toolchain_config(
    name = "config",
    archiver = "@llvm_darwin_aarch64//:ar",
    c_compiler = "@llvm_darwin_aarch64//:clang",
    cc_compiler = "@llvm_darwin_aarch64//:clang++",
    compiler_features = [
        # Hermetic libraries feature required before import.
        "//third_party/rules_cc_toolchain/features:hermetic_libraries",
        ":imports_feature",
        "//third_party/rules_cc_toolchain/features:undefined_symbols",

        # Toolchain configuration
        "//third_party/rules_cc_toolchain/features:warnings",
        "//third_party/rules_cc_toolchain/features:errors",
        "//third_party/rules_cc_toolchain/features:reproducible",
        "//third_party/rules_cc_toolchain/features:language",
        "//third_party/rules_cc_toolchain/features:use_lld",
        "//cc/features:sysroot_darwin_aarch64",
        "//third_party/rules_cc_toolchain/features:coverage",
        #"//cc/features:clang19",    # TODO: Add a selection mechanism based on the Clang version
        "//cc/features:max_install_names",
        "//cc/features:no_elaborated_enum_base",

        # PIC / PIE flags
        "//third_party/rules_cc_toolchain/features:supports_pic",
        "//third_party/rules_cc_toolchain/features:position_independent_code",

        # Optimization flags
        "//cc/features:garbage_collect_symbols_mac",
        "//cc/features:constants_merge",
        "//cc/features:asserts_disable",
        "//third_party/rules_cc_toolchain/features:dbg",
        "//third_party/rules_cc_toolchain/features:opt",
        "//cc/features:detect_issues",

        # C++ standard configuration
        "//third_party/rules_cc_toolchain/features:c++11",
        "//third_party/rules_cc_toolchain/features:c++14",
        "//third_party/rules_cc_toolchain/features:c++17",

        #
        # "//cc/features:allow_shlib_undefined",  # Instead of --allow-shlib-undefined, macOS uses the -undefined flag with dynamic_lookup as an argument.
        "//cc/features:supports_dynamic_linker",
        "//cc/features:supports_start_end_lib_feature",
    ],
    dynamic_library_extension = ".dylib",
    install_name = "@llvm_darwin_aarch64//:install_name_tool_darwin",
    linker = "@llvm_darwin_aarch64//:ld",
    strip_tool = "@llvm_darwin_aarch64//:strip",
    target_cpu = "aarch64",
    target_libc = "macosx",
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
    toolchain_identifier = "toolchain_id_darwin_aarch64_darwin_aarch64",
)
