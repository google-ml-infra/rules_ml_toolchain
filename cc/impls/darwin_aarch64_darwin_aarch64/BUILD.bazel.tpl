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

# ==============================================================================
# Tools: macOS aarch64, Sysroot: macOS aarch64
# ==============================================================================

load("@rules_cc//cc:defs.bzl", "cc_toolchain")
load("@rules_ml_toolchain//third_party/rules_cc_toolchain:toolchain_config.bzl", "cc_toolchain_config")
load("@rules_ml_toolchain//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl", "cc_toolchain_import")
load("@rules_ml_toolchain//third_party/rules_cc_toolchain/features:features.bzl", "cc_toolchain_import_feature")

package(
    default_visibility = [
        "//visibility:public",
    ],
)

filegroup(
    name = "wrappers",
    srcs = [
        "@darwin_local_config_cc//wrappers:all",
    ],
    visibility = ["//visibility:public"],
)

# buildifier: leave-alone
cc_toolchain_import(
    name = "imports",
    deps = [
        "@sysroot_darwin_aarch64//:std_incs",
        "@llvm_darwin_aarch64//:compiler_incs",
        "@sysroot_darwin_aarch64//:sys_incs",
        "@sysroot_darwin_aarch64//:sys_libs",
        "@llvm_darwin_aarch64//:libclang_rt",
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
        "@xcode_darwin//:all",
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
    cxx_builtin_include_directories = [
        "%workspace%/external/%{SYSROOT}/usr/include/c++/v1",
        "%workspace%/external/%{SYSROOT}/usr/include",
        "%workspace%/external/%{SYSROOT}/System/Library/Frameworks",
    ],
    compiler_features = [
        # Hermetic libraries feature required before import.
        "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:hermetic",

        ":imports_feature",
        "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:undefined_symbols",

        # Toolchain configuration
        "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:warnings",
        "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:errors",
        "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:reproducible",
        "@rules_ml_toolchain//cc/features:language",
        "@rules_ml_toolchain//cc/features/darwin/aarch64:sysroot",
        "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:coverage",
        #"@rules_ml_toolchain//cc/features:clang19",    # TODO: Add a selection mechanism based on the Clang version
        "@rules_ml_toolchain//cc/features:max_install_names",
        "@rules_ml_toolchain//cc/features:no_elaborated_enum_base",

        # PIC / PIE flags
        "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:supports_pic",
        "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:position_independent_code",

        # Optimization flags
        "@rules_ml_toolchain//cc/features:dbg",
        "@rules_ml_toolchain//cc/features:fastbuild",
        "@rules_ml_toolchain//cc/features:opt",

        "@rules_ml_toolchain//cc/features:garbage_collect_symbols_mac",
        "@rules_ml_toolchain//cc/features:constants_merge",
        "@rules_ml_toolchain//cc/features:detect_issues",

        # C++ standard configuration
        "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:c++11",
        "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:c++14",
        "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:c++17",
        "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:c++20",

        # Instead of --allow-shlib-undefined, macOS uses the -undefined flag with dynamic_lookup as an argument.
        # "@rules_ml_toolchain//cc/features:allow_shlib_undefined",
        "@rules_ml_toolchain//cc/features:supports_start_end_lib_feature",

        "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:use_lld",
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
