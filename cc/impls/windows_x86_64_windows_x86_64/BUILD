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
# Tools: Windows x86_64 (@llvm_windows_x86_64), Host Sysroot: Windows MSVC
# ==============================================================================

load("@rules_cc//cc:defs.bzl", "cc_toolchain")
load(
    "@sysroot_windows_x86_64//:defs.bzl",
    "MSVC_CXX_BUILTIN_INCLUDE_DIRECTORIES",
)
load(
    "//cc/sanitizers:features.bzl",
    "cc_toolchain_import_asan_feature",
)
load("//third_party/rules_cc_toolchain:toolchain_config.bzl", "cc_toolchain_config")
load("//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl", "cc_toolchain_import")
load("//third_party/rules_cc_toolchain/features:features.bzl", "cc_toolchain_import_feature")

package(
    default_visibility = [
        "//cc:__pkg__",
        "//cc/impls/cpu:__pkg__",
    ],
)

filegroup(
    name = "wrappers",
    srcs = [
        "//cc/impls/windows_x86_64_windows_x86_64/wrappers:all",
    ],
    visibility = ["//visibility:public"],
)

# buildifier: leave-alone
cc_toolchain_import(
    name = "imports",
    deps = [
        "@llvm_windows_x86_64//:compiler_incs",
        "@llvm_windows_x86_64//:libclang_rt",
    ],
    visibility = ["//visibility:public"],
)

cc_toolchain_import_feature(
    name = "imports_feature",
    enabled = True,
    is_windows = True,
    toolchain_import = ":imports",
)

cc_toolchain_import(
    name = "asan_import",
    deps = [
        "@llvm_windows_x86_64//:libclang_rt",
        "@llvm_windows_x86_64//:rt_asan",
    ],
)

cc_toolchain_import_asan_feature(
    name = "asan",
    is_windows = True,
    toolchain_import = ":asan_import",
)

# buildifier: leave-alone
filegroup(
    name = "all",
    srcs = [
        ":imports",
        ":wrappers",
        "@llvm_windows_x86_64//:all",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "compiler",
    srcs = [
        ":asan_import",
        ":imports",
        ":wrappers",
        "@llvm_windows_x86_64//:clang-cl",
        "@llvm_windows_x86_64//:llvm-ml",
        "@llvm_windows_x86_64//:scan_deps",
        "@llvm_windows_x86_64//:distro_libs",
        "@llvm_windows_x86_64//:asan_ignorelist",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "linker",
    srcs = [
        ":compiler",
        ":wrappers",
        "@llvm_windows_x86_64//:lld-link",
        "@llvm_windows_x86_64//:distro_libs",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "ar",
    srcs = [
        ":wrappers",
        "@llvm_windows_x86_64//:llvm-lib",
        "@llvm_windows_x86_64//:distro_libs",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "objcopy",
    srcs = [
        ":wrappers",
        "@llvm_windows_x86_64//:objcopy",
        "@llvm_windows_x86_64//:distro_libs",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "strip",
    srcs = [
        ":wrappers",
        "@llvm_windows_x86_64//:strip",
        "@llvm_windows_x86_64//:distro_libs",
    ],
)

FEATURES_ESSENTIAL = [
    "//cc/features/windows:no_legacy_features",
    "//cc/features/windows:nologo",
    "//cc/features/windows:has_configured_linker_path",
    "//cc/features/windows:no_stripping",
    "//cc/features/windows:targets_windows",
    "//cc/features/windows:copy_dynamic_libraries_to_binary",
    "//cc/features/windows:default_cpp_std",
    "//cc/features/windows:c++11",
    "//cc/features/windows:c++14",
    "//cc/features/windows:c++17",
    "//cc/features/windows:c++20",
    "//cc/features/windows:default_compile_flags",
    "//cc/features/windows:msvc_env",
    "//cc/features/windows:msvc_compile_env",
    "//cc/features/windows:msvc_link_env",
    "//cc/features/windows:include_paths",
    "//cc/features/windows:external_include_paths",
    ":imports_feature",
    "//cc/features/windows:preprocessor_defines",
    "//cc/features/windows:parse_showincludes",
    "//cc/features/windows:no_dotd_file",
    "//cc/features/windows:shorten_virtual_includes",
    "//cc/features/windows:generate_pdb_file",
    "//cc/features/windows:generate_linkmap",
    "//cc/features/windows:shared_flag",
    "//cc/features/windows:linkstamps",
    "//cc/features/windows:output_execpath_flags",
    "//cc/features/windows:archiver_flags",
    "//cc/features/windows:input_param_flags",
    "//cc/features/windows:linker_subsystem_flag",
    "//cc/features/windows:user_link_flags",
    "//cc/features/windows:default_link_flags",
    "//cc/features/windows:linker_param_file",
    "//cc/features/windows:static_link_msvcrt",
    "//cc/features/windows:dynamic_link_msvcrt",
    "//cc/features/windows:dbg",
    "//cc/features/windows:fastbuild",
    "//cc/features/windows:opt",
    "//cc/features/windows:frame_pointer",
    "//cc/features/windows:disable_assertions",
    "//cc/features/windows:determinism",
    "//cc/features/windows:treat_warnings_as_errors",
    "//cc/features/windows:smaller_binary",
    "//cc/features/windows:remove_unreferenced_code",
    "//cc/features/windows:ignore_noisy_warnings",
    "//cc/features/windows:user_compile_flags",
    "//cc/features/windows/x86_64:sysroot",
    "//cc/features/windows:unfiltered_compile_flags",
    "//cc/features/windows:archive_param_file",
    "//cc/features/windows:compiler_param_file",
    "//cc/features/windows:windows_quoting_for_param_files",
    "//cc/features/windows:compiler_output_flags",
    "//cc/features/windows:compiler_input_flags",
    "//cc/features/windows:def_file",
    "//cc/features/windows:windows_export_all_symbols",
    "//cc/features/windows:no_windows_export_all_symbols",
    "//cc/features/windows:supports_dynamic_linker",
    "//cc/features/windows:supports_interface_shared_libraries",
    "//cc/features/windows:symbol_check",
    "//cc/features:cpp_modules",
    "//cc/features:cpp_module_modmap_file",
    "//cc/features/windows:cpp20_module_compile_flags",
    ":asan",
]

cc_toolchain_config(
    name = "config",
    abi_libc_version = "local",
    abi_version = "local",
    archiver = "@llvm_windows_x86_64//:llvm-lib",
    assembler = "@llvm_windows_x86_64//:clang-cl",
    c_compiler = "@llvm_windows_x86_64//:clang-cl",
    cc_compiler = "@llvm_windows_x86_64//:clang-cl",
    compiler = "clang-cl",
    compiler_features = FEATURES_ESSENTIAL,
    cxx_builtin_include_directories = MSVC_CXX_BUILTIN_INCLUDE_DIRECTORIES,
    headers_parser = "@llvm_windows_x86_64//:clang-cl",
    linker = "@llvm_windows_x86_64//:lld-link",
    module_deps_scanner = "@llvm_windows_x86_64//:scan_deps",
    strip_tool = "@llvm_windows_x86_64//:strip",
    target_cpu = "x64_windows",
    target_libc = "msvcrt",
    target_system_name = "local",
    tool_paths = {
        "ar": "wrappers/ar.bat",
        "cpp": "wrappers/clang++.bat",
        "cpp-module-deps-scanner": "wrappers/module-deps-scanner.bat",
        "gcc": "wrappers/clang.bat",
        "gcov": "wrappers/idler.bat",
        "ld": "wrappers/ld.bat",
        "llvm-cov": "wrappers/idler.bat",
        "ml": "wrappers/ml.bat",
        "nm": "wrappers/idler.bat",
        "objcopy": "wrappers/objcopy.bat",
        "objdump": "wrappers/idler.bat",
        "strip": "wrappers/strip.bat",
    },
    toolchain_identifier = "toolchain_windows_x86_64_windows_x86_64_id",
)

cc_toolchain(
    name = "toolchain",
    all_files = ":all",
    ar_files = ":ar",
    as_files = ":compiler",
    compiler_files = ":compiler",
    dwp_files = ":all",
    linker_files = ":linker",
    objcopy_files = ":objcopy",
    strip_files = ":strip",
    supports_param_files = 1,
    toolchain_config = ":config",
    toolchain_identifier = "toolchain_windows_x86_64_windows_x86_64_id",
)
