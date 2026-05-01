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
# ROCm cc_toolchain with hipcc compiler
# ==============================================================================
#
# This toolchain provides:
# 1. hipcc as the C++ compiler (for rocm_compile rule to use)
# 2. ROCm include directories (clang headers, HIP headers)
# 3. ROCm compiler flags via rocm_hipcc_feature
# 4. Standard linking capability for combining compiled .o files

load("@config_rocm_hipcc//rocm:build_defs.bzl", "hipcc_config")
load("@rules_cc//cc:defs.bzl", "cc_toolchain")
load("//cc/rocm/features:rocm_hipcc_feature.bzl", "rocm_hipcc_feature")
load("//third_party/rules_cc_toolchain:toolchain_config.bzl", "cc_toolchain_config")
load("//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl", "cc_toolchain_import")
load("//third_party/rules_cc_toolchain/features:features.bzl", "cc_toolchain_import_feature")

package(
    default_visibility = [
        "//cc:__pkg__",
    ],
)

# =============================================================================
# ROCm HIPcc Feature
# =============================================================================

rocm_hipcc_feature(
    name = "rocm_hipcc_feature",
    amdgpu_targets = hipcc_config().gpu_architectures,
    clang_version = hipcc_config().clang_version,
    enabled = True,
    hipcc_path = hipcc_config().hipcc_path,
    rocm_path = hipcc_config().rocm_root,
    rocm_toolkit = "@config_rocm_hipcc//rocm:rocm_root",
    version = str(hipcc_config().version_number),
    visibility = ["//visibility:public"],
)

# =============================================================================
# Filegroups
# =============================================================================

alias(
    name = "startup_libs",
    actual = "@sysroot_linux_x86_64//:startup_libs",
    visibility = ["//visibility:public"],
)

cc_toolchain_import_feature(
    name = "startup_libs_feature",
    enabled = True,
    toolchain_import = ":startup_libs",
)

cc_toolchain_import(
    name = "imports",
    visibility = ["//visibility:public"],
    deps = [
        # Use sysroot's C and system headers
        "@sysroot_linux_x86_64//:includes_c",
        "@sysroot_linux_x86_64//:includes_system",
        # Use sysroot's libstdc++ (NOT hermetic libc++)
        # This matches what ROCm libraries were built with
        "@sysroot_linux_x86_64//:syslibs",
    ],
)

cc_toolchain_import_feature(
    name = "imports_feature",
    enabled = True,
    toolchain_import = ":imports",
)

filegroup(
    name = "compiler",
    srcs = [
        ":imports",
        "@config_rocm_hipcc//rocm:toolchain_data",
        "@llvm_linux_x86_64//:distro_libs",
    ],
)

filegroup(
    name = "linker",
    srcs = [
        ":imports",
        ":startup_libs",
        "@config_rocm_hipcc//rocm:ld",
        "@config_rocm_hipcc//rocm:toolchain_data",
    ],
)

filegroup(
    name = "ar",
    srcs = [
        "@config_rocm_hipcc//rocm:ar",
        "@config_rocm_hipcc//rocm:toolchain_data",
    ],
)

filegroup(
    name = "strip",
    srcs = [
        "@config_rocm_hipcc//rocm:strip",
        "@config_rocm_hipcc//rocm:toolchain_data",
    ],
)

filegroup(
    name = "objcopy",
    srcs = [
        "@config_rocm_hipcc//rocm:objcopy",
        "@config_rocm_hipcc//rocm:toolchain_data",
    ],
)

filegroup(
    name = "all",
    srcs = [
        ":ar",
        ":compiler",
        ":linker",
        ":objcopy",
        ":strip",
    ],
)

# =============================================================================
# Features
# =============================================================================

FEATURES_ESSENTIAL = [
    # Library imports
    ":imports_feature",

    # ROCm-specific features
    ":rocm_hipcc_feature",

    # Sysroot and C++ library (always hermetic for ROCm)
    ":startup_libs_feature",
    "//cc/features:sysroot_linux_x86_64",
    "//cc/features:use_libstdcxx",
    "//cc/features:static_libstdcxx",

    # Toolchain configuration
    "//third_party/rules_cc_toolchain/features:warnings",
    "//third_party/rules_cc_toolchain/features:reproducible",
    "//third_party/rules_cc_toolchain/features:use_lld",
    "//third_party/rules_cc_toolchain/features:supports_pic",
    "//third_party/rules_cc_toolchain/features:position_independent_code",
    "//third_party/rules_cc_toolchain/features:garbage_collect_symbols",
    "//cc/features:constants_merge",
    "//cc/features:dbg",
    "//cc/features:fastbuild",
    "//cc/features:opt",
    "//cc/features:detect_issues",
    "//third_party/rules_cc_toolchain/features:c++17",
    "//cc/features:allow_shlib_undefined",
    "//cc/features:supports_dynamic_linker",
    "//cc/features:supports_start_end_lib_feature",
]

# =============================================================================
# Toolchain Configuration
# =============================================================================

cc_toolchain_config(
    name = "config",
    archiver = "@config_rocm_hipcc//rocm:ar",
    c_compiler = "@config_rocm_hipcc//rocm:hipcc",
    cc_compiler = "@config_rocm_hipcc//rocm:hipcc",
    compiler_features = FEATURES_ESSENTIAL,
    cxx_builtin_include_directories = [
        # ROCm clang builtin includes (needed for __clang_hip_runtime_wrapper.h, etc.)
        hipcc_config().rocm_root + "/llvm/lib/clang/" + hipcc_config().clang_version + "/include",
        hipcc_config().rocm_root + "/include",
    ],
    linker = "@config_rocm_hipcc//rocm:ld",
    strip_tool = "@config_rocm_hipcc//rocm:strip",
    target_cpu = "x86_64",
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
    toolchain_identifier = "toolchain_linux_x86_64_linux_x86_64_rocm_id",
    visibility = ["//visibility:public"],
)
