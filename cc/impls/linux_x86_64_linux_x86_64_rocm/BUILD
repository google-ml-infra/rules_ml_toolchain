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
load("//cc/config:constants.bzl", "LIBCXX_FLAGS", "LIBSTDCXX_FLAGS")
load("//cc/rocm/features:rocm_hipcc_feature.bzl", "rocm_hipcc_feature")
load("//third_party/rules_cc_toolchain:toolchain_config.bzl", "cc_toolchain_config")
load("//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl", "cc_toolchain_import")
load("//third_party/rules_cc_toolchain/features:features.bzl", "cc_feature", "cc_toolchain_import_feature")

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

cc_toolchain_import(
    name = "empty_startup_libs",
    deps = [],
)

alias(
    name = "startup_libs",
    actual = "@sysroot_linux_x86_64//:startup_libs",
    visibility = ["//visibility:public"],
)

cc_toolchain_import_feature(
    name = "startup_libs_feature",
    enabled = select({
        "//common:is_hermetic_libraries_enabled": True,
        "//conditions:default": False,
    }),
    toolchain_import = ":startup_libs",
)

# buildifier: leave-alone
cc_toolchain_import(
    name = "imports",
    deps = [
        # Always include hermetic sysroot headers - needed for GPU compilation
        # GPU compilation requires hermetic headers (system headers incompatible with ROCm clang)
        # Host compilation will use system headers when HOST_SYSROOT is set (via wrapper override)
        # IMPORTANT: std_incs must come before compiler_incs to ensure correct stdatomic.h resolution
        # The sysroot C++ stdatomic.h wrapper uses #include_next to find clang's built-in stdatomic.h
        "@sysroot_linux_x86_64//:std_incs",
        # Hermetic LLVM headers
        "@llvm_linux_x86_64//:compiler_incs",
        "@sysroot_linux_x86_64//:sys_incs",
        ":std_libs",
        "@sysroot_linux_x86_64//:sys_libs",
    ],
    visibility = ["//visibility:public"],
)

config_setting(
    name = "is_static_libcxx",
    flag_values = {
        "//common:stdlib": "libc++",
        "//common:static_libcxx": "True",
    },
)

config_setting(
    name = "is_static_libstdcxx",
    flag_values = {
        "//common:stdlib": "libstdc++",
        "//common:static_libcxx": "True",
    },
)

# Feature to force static linking of libstdc++
# Use compiler's built-in flags for static linking
cc_feature(
    name = "static_link_libstdcxx",
    enabled = select({
        ":is_static_libstdcxx": True,
        "//conditions:default": False,
    }),
    linker_flags = [
        "-static-libstdc++",
        "-static-libgcc",
    ],
)

cc_toolchain_import_feature(
    name = "imports_feature",
    enabled = True,
    toolchain_import = ":imports",
)

# Conditional hermetic libraries feature
# Disabled by default for XLA (to avoid -nodefaultlibs issues with ROCm)
# Can be enabled via --@rules_ml_toolchain//common:enable_hermetic_libraries=True
cc_feature(
    name = "hermetic_libraries_conditional",
    cc_flags = ["-nostdinc++"],
    compiler_flags = ["-nostdinc"],
    enabled = select({
        "//common:is_hermetic_libraries_enabled": True,
        "//conditions:default": False,
    }),
    linker_flags = [
        "-nostdlib",
        "-nodefaultlibs",
    ],
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
    # Conditional hermetic libraries (disabled by default for XLA)
    ":hermetic_libraries_conditional",
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
    "//cc/features:sysroot_linux_x86_64",
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
    cxx_builtin_include_directories = [],
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

# Aliases to select between libc++ and libstdc++
alias(
    name = "std_incs",
    actual = select({
        "//common:is_stdlib_libcxx": "@llvm_linux_x86_64//:std_incs",
        "//conditions:default": "@sysroot_linux_x86_64//:std_incs",
    }),
)

alias(
    name = "std_libs",
    actual = select({
        "//common:is_stdlib_libcxx": "@llvm_linux_x86_64//:std_libs",
        "//conditions:default": "@sysroot_linux_x86_64//:std_libs",
    }),
)
