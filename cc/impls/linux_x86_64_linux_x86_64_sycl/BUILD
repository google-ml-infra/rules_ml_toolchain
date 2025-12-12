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
# Tools: Linux x86_64, Sysroot: Linux x86_64, SYCL
# ==============================================================================

load("@rules_cc//cc:defs.bzl", "cc_toolchain")
load("//third_party/rules_cc_toolchain:toolchain_config.bzl", "cc_toolchain_config")
load("//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl", "cc_toolchain_import")
load("//third_party/rules_cc_toolchain/features:features.bzl", "cc_toolchain_import_feature")

package(
    default_visibility = [
        "//cc:__pkg__",
    ],
)

SYCL_TOOLS = {
    "gcc": "wrappers/icpx_wrapper",
    "cpp": "wrappers/clang++",
    "ld": "wrappers/ld",
    "ar": "wrappers/ar_wrapper",
    "gcov": "wrappers/idler",
    "llvm-cov": "wrappers/idler",
    "nm": "wrappers/idler",
    "objdump": "wrappers/idler",
    "strip": "wrappers/idler",
}

filegroup(
    name = "wrappers",
    srcs = [
        "//cc/impls/linux_x86_64_linux_x86_64_sycl/wrappers:all",
    ],
)

filegroup(
    name = "oneapi",
    srcs = [
        "@oneapi//:all",
    ],
)

alias(
    name = "oneapi_feature",
    actual = "@oneapi//:feature",
)

alias(
    name = "startup_libs",
    actual = "@sysroot_linux_x86_64//:startup_libs",
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
        "@sysroot_linux_x86_64//:includes_c",
        "@oneapi//:includes",
        "@sysroot_linux_x86_64//:includes_system",
        "@sysroot_linux_x86_64//:syslibs",
        "@oneapi//:core",
        "@oneapi//:mkl",
        "@oneapi//:libclang_rt",
    ],
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
        "@oneapi//:all",
        "@llvm_linux_x86_64//:all",
        "@level_zero//:all",
        "@zero_loader//:all",
        ":imports",
        ":wrappers",
        ":startup_libs",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "compiler",
    srcs = [
        ":imports",
        ":wrappers",
        "@oneapi//:icpx",
        "@oneapi//:clang",
        "@oneapi//:clang++",
        "@oneapi//:clang-offload-bundler",
        "@oneapi//:clang-offload-wrapper",
        "@oneapi//:file-table-tform",
        "@oneapi//:llvm-foreach",
        "@oneapi//:llvm-objcopy",
        "@oneapi//:llvm-link",
        "@oneapi//:llvm-spirv",
        "@oneapi//:sycl-post-link",
        "@oneapi//:spirv-to-ir-wrapper",
        "@llvm_linux_x86_64//:clang",
        "@llvm_linux_x86_64//:clang++",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "linker",
    srcs = [
        ":compiler",
        ":wrappers",
        "@oneapi//:ld",
        "@llvm_linux_x86_64//:ld",
        ":startup_libs",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "ar",
    srcs = [
        ":wrappers",
        "@oneapi//:ar",
        "@llvm_linux_x86_64//:ar",
    ],
)

cc_toolchain_config(
    name = "config",
    archiver = "@oneapi//:ar",
    c_compiler = "@oneapi//:clang",
    cc_compiler = "@oneapi//:clang++",
    compiler_features = [
        ":imports_feature",
        "@oneapi//:binaries",

        # Hermetic libraries feature required before import.
        "//third_party/rules_cc_toolchain/features:hermetic_libraries",

        # Toolchain configuration
        "//third_party/rules_cc_toolchain/features:warnings",
        "//third_party/rules_cc_toolchain/features:errors",
        "//third_party/rules_cc_toolchain/features:reproducible",
        "//third_party/rules_cc_toolchain/features:use_lld",
        "//cc/features:sysroot_linux_x86_64",
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
        #"//cc/features:detect_issues_ext",   # Non-hermetic builds don't include these flags

        # C++ standard configuration
        "//third_party/rules_cc_toolchain/features:c++11",
        "//third_party/rules_cc_toolchain/features:c++14",
        "//third_party/rules_cc_toolchain/features:c++17",

        #
        "//cc/features:allow_shlib_undefined",
        "//cc/features:supports_dynamic_linker",
        "//cc/features:supports_start_end_lib_feature",
        "//cc/impls/linux_x86_64_linux_x86_64_sycl/features:no_as_needed",
        "//cc/impls/linux_x86_64_linux_x86_64_sycl/features:runtime_library_search_directories",
    ],
    linker = "@oneapi//:ld",
    target_cpu = "x86_64",
    target_system_name = "local",
    tool_paths = SYCL_TOOLS,
)

cc_toolchain(
    name = "toolchain",
    all_files = ":all",
    ar_files = ":ar",
    compiler_files = ":compiler",
    dwp_files = ":all",
    linker_files = ":linker",
    objcopy_files = ":empty",
    strip_files = ":empty",
    supports_param_files = 1,
    toolchain_config = ":config",
    toolchain_identifier = "toolchain_linux_x86_64_linux_x86_64_id",
)
