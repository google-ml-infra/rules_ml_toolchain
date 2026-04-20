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
# Tools: Linux x86_64, Sysroot: Linux x86_64, ROCm
# ==============================================================================

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

ROCM_TOOLS = {
    "gcc": "wrappers/hipcc_wrapper",
    "cpp": "wrappers/clang++",
    "ld": "wrappers/ld",
    "ar": "wrappers/ar",
    "gcov": "wrappers/idler",
    "llvm-cov": "wrappers/idler",
    "nm": "wrappers/idler",
    "objdump": "wrappers/idler",
    "strip": "wrappers/idler",
}

# =============================================================================
# ROCm HIPcc Feature
# =============================================================================

rocm_hipcc_feature(
    name = "rocm_hipcc_feature",
    amdgpu_targets = hipcc_config().gpu_architectures,
    clang_version = hipcc_config().clang_version,
    enabled = True,
    hipcc_path = hipcc_config().hipcc_path,
    host_compiler = "@llvm_linux_x86_64//:clang",
    rocm_path = hipcc_config().rocm_path,
    rocm_toolkit = "@config_rocm_hipcc//rocm:rocm_root",
    version = str(hipcc_config().version_number),
    visibility = ["//visibility:public"],
)

# =============================================================================
# Filegroups
# =============================================================================

filegroup(
    name = "wrappers",
    srcs = ["//cc/impls/linux_x86_64_linux_x86_64_rocm/wrappers:all"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "rocm_toolkit_files",
    srcs = [
        "@config_rocm_hipcc//rocm:toolchain_data",
    ],
)

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

# buildifier: leave-alone
cc_toolchain_import(
    name = "imports",
    deps = [
        # Hermetic LLVM headers for host compilation
        # ROCm LLVM headers are in rocm_toolkit_files and added via hipcc_wrapper for GPU
        "@llvm_linux_x86_64//:includes",
        "@llvm_linux_x86_64//:libclang_rt",
        "@sysroot_linux_x86_64//:includes_c",
        "@sysroot_linux_x86_64//:includes_system",
        "@sysroot_linux_x86_64//:syslibs",
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
        ":rocm_toolkit_files",
        ":startup_libs",
        ":wrappers",
        "@llvm_linux_x86_64//:all",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "compiler",
    srcs = [
        ":imports",
        ":rocm_toolkit_files",
        ":wrappers",
        "@llvm_linux_x86_64//:clang",
        "@llvm_linux_x86_64//:clang++",
        "@llvm_linux_x86_64//:distro_libs",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "linker",
    srcs = [
        ":compiler",
        ":rocm_toolkit_files",
        ":startup_libs",
        ":wrappers",
        "@llvm_linux_x86_64//:distro_libs",
        "@llvm_linux_x86_64//:ld",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "ar",
    srcs = [
        ":rocm_toolkit_files",
        ":wrappers",
        "@llvm_linux_x86_64//:ar",
        "@llvm_linux_x86_64//:distro_libs",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "strip",
    srcs = [
        ":wrappers",
        "@llvm_linux_x86_64//:distro_libs",
        "@llvm_linux_x86_64//:strip",
    ],
)

# =============================================================================
# Features
# =============================================================================

FEATURES_ESSENTIAL = [
    # Hermetic libraries (must come first)
    "//third_party/rules_cc_toolchain/features:hermetic_libraries",

    # Library imports
    ":imports_feature",
    ":startup_libs_feature",

    # ROCm-specific features
    ":rocm_hipcc_feature",
    "//cc/rocm/features:rocm_defines",
    "//cc/rocm/features:rocm_hermetic",
    "//cc/rocm/features:rocm_warnings",

    # Toolchain configuration
    "//third_party/rules_cc_toolchain/features:warnings",
    "//third_party/rules_cc_toolchain/features:reproducible",
    "//third_party/rules_cc_toolchain/features:use_lld",
] + select({
    "//cc/sysroots:local_sysroot_enabled": ["//cc/features:local_sysroot_linux_x86_64"],
    "//conditions:default": ["//cc/features:sysroot_linux_x86_64"],
}) + [
    # PIC / PIE flags
    "//third_party/rules_cc_toolchain/features:supports_pic",
    "//third_party/rules_cc_toolchain/features:position_independent_code",
    "//third_party/rules_cc_toolchain/features:position_independent_executable",

    # Optimization flags
    "//third_party/rules_cc_toolchain/features:garbage_collect_symbols",
    "//cc/features:constants_merge",
    "//cc/features:dbg",
    "//cc/features:fastbuild",
    "//cc/features:opt",
    "//cc/features:detect_issues",

    # C++ standard flags
    "//third_party/rules_cc_toolchain/features:c++17",

    # Other flags
    "//cc/features:allow_shlib_undefined",
    "//cc/features:supports_dynamic_linker",
    "//cc/features:supports_start_end_lib_feature",
]

# =============================================================================
# Toolchain Configuration
# =============================================================================

cc_toolchain_config(
    name = "config",
    archiver = "@llvm_linux_x86_64//:ar",
    c_compiler = "@llvm_linux_x86_64//:clang",
    cc_compiler = "@llvm_linux_x86_64//:clang++",
    compiler_features = FEATURES_ESSENTIAL,
    linker = "@llvm_linux_x86_64//:ld",
    strip_tool = "@llvm_linux_x86_64//:strip",
    target_cpu = "x86_64",
    target_system_name = "local",
    tool_paths = ROCM_TOOLS,
)

cc_toolchain(
    name = "toolchain",
    all_files = ":all",
    ar_files = ":ar",
    as_files = ":compiler",
    compiler_files = ":compiler",
    dwp_files = ":all",
    linker_files = ":linker",
    objcopy_files = ":all",
    strip_files = ":strip",
    supports_param_files = 1,
    toolchain_config = ":config",
    toolchain_identifier = "toolchain_linux_x86_64_linux_x86_64_rocm_id",
)
