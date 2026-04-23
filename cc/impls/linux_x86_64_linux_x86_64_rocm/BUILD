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
# Tools: Linux x86_64, ROCm GPU Compilation
#
# This toolchain uses HIPcc and is ONLY for GPU code compilation.
# CPU code in ROCm builds uses the default hermetic LLVM toolchain.
#
# Toolchain selection:
#   - GPU code: rocm_library() adds rocm_gpu_compilation constraint → selects this toolchain
#   - CPU code: cc_library() uses default cpu_compilation constraint → selects hermetic LLVM
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

# =============================================================================
# ROCm HIPcc Feature
# =============================================================================

rocm_hipcc_feature(
    name = "rocm_hipcc_feature",
    amdgpu_targets = hipcc_config().gpu_architectures,
    clang_version = hipcc_config().clang_version,
    enabled = True,
    hipcc_path = hipcc_config().hipcc_path,
    host_compiler = "",  # HIPcc doesn't use separate host compiler
    rocm_path = hipcc_config().rocm_path,
    rocm_toolkit = "@config_rocm_hipcc//rocm:rocm_root",
    version = str(hipcc_config().version_number),
    visibility = ["//visibility:public"],
)

# Tool paths - use simple wrappers that call tools from @config_rocm_hipcc
ROCM_HIPCC_TOOLS = {
    "gcc": "wrappers/hipcc_direct",
    "cpp": "wrappers/hipcc_direct",
    "ld": "wrappers/hipcc_direct",
    "ar": "wrappers/llvm-ar",
    "gcov": "wrappers/idler",
    "llvm-cov": "wrappers/idler",
    "nm": "wrappers/idler",
    "objdump": "wrappers/idler",
    "strip": "wrappers/llvm-strip",
}

# =============================================================================
# Filegroups
# =============================================================================

filegroup(
    name = "wrappers",
    srcs = ["//cc/impls/linux_x86_64_linux_x86_64_rocm_hipcc/wrappers:all"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "rocm_toolkit_files",
    srcs = [
        "@config_rocm_hipcc//rocm:toolchain_data",
    ],
)

cc_toolchain_import(
    name = "empty_startup_libs",
    deps = [],
)

cc_toolchain_import_feature(
    name = "startup_libs_feature",
    enabled = True,
    toolchain_import = ":empty_startup_libs",
)

# HIPcc provides all headers via cxx_builtin_include_directories
cc_toolchain_import(
    name = "imports",
    deps = [],
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
        ":rocm_toolkit_files",
        ":wrappers",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "compiler",
    srcs = [
        ":rocm_toolkit_files",
        ":wrappers",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "linker",
    srcs = [
        ":compiler",
        ":rocm_toolkit_files",
        ":wrappers",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "ar",
    srcs = [
        ":rocm_toolkit_files",
        ":wrappers",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "strip",
    srcs = [
        ":rocm_toolkit_files",
        ":wrappers",
    ],
)

# =============================================================================
# Features
# =============================================================================

FEATURES_HIPCC = [
    # Library imports
    ":imports_feature",
    ":startup_libs_feature",

    # ROCm-specific features
    ":rocm_hipcc_feature",
    "//cc/rocm/features:rocm_defines",
    "//cc/rocm/features:rocm_warnings",

    # Basic toolchain features
    "//third_party/rules_cc_toolchain/features:warnings",
    "//third_party/rules_cc_toolchain/features:reproducible",

    # PIC / PIE flags
    "//third_party/rules_cc_toolchain/features:supports_pic",
    "//third_party/rules_cc_toolchain/features:position_independent_code",

    # Optimization flags
    "//cc/features:dbg",
    "//cc/features:fastbuild",
    "//cc/features:opt",

    # C++ standard flags
    "//third_party/rules_cc_toolchain/features:c++17",
]

# =============================================================================
# Toolchain Configuration
# =============================================================================

cc_toolchain_config(
    name = "config",
    archiver = "@config_rocm_hipcc//rocm:ar",
    c_compiler = "@config_rocm_hipcc//rocm:hipcc",
    cc_compiler = "@config_rocm_hipcc//rocm:hipcc",
    compiler_features = FEATURES_HIPCC,
    cxx_builtin_include_directories = hipcc_config().include_directories,
    linker = "@config_rocm_hipcc//rocm:hipcc",
    strip_tool = "@config_rocm_hipcc//rocm:strip",
    target_cpu = "x86_64",
    target_system_name = "local",
    tool_paths = ROCM_HIPCC_TOOLS,
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
