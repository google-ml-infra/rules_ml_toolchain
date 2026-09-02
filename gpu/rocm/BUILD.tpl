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

load("@rules_cc//cc:defs.bzl", "cc_library")
load("@rules_ml_toolchain//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl", "cc_toolchain_import")

licenses(["restricted"])  # MPL2, portions GPL v3, LGPL v3, BSD-like

package(default_visibility = ["//visibility:private"])

# Export rocm_dist directory so it can be referenced directly as a label by XLA
# XLA's rocm_configure needs to symlink this directory into its own repository
exports_files(
    ["rocm_dist"],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "hip_runtime",
    srcs = glob(
        [
            "%{rocm_root}/lib/libamdhip64.so*",
            "%{rocm_root}/lib/libhsa-runtime64.so*",
            "%{rocm_root}/lib/librocprofiler-register.so.0*",
            "%{rocm_root}/lib/libamd_comgr.so*",
            "%{rocm_root}/lib/libamd_comgr_loader.so*",
            "%{rocm_root}/lib/rocm_sysdeps/lib/*.so*",
            "%{rocm_root}/llvm/lib/libclang-cpp.so*",
            "%{rocm_root}/llvm/lib/libLLVM.so.*",
        ],
        allow_empty = True,
        exclude = [
            "%{rocm_root}/**/libamdhip64.so.*.*.*",
        ],
    ),
    hdrs = glob(
        ["%{rocm_root}/include/**/*.h"],
        allow_empty = True,
    ),
    includes = ["%{rocm_root}/include"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "toolchain_data",
    srcs = glob(
        ["%{rocm_root}/**"],
        allow_empty = True,
        exclude = [
            "%{rocm_root}/tests/**",
            "%{rocm_root}/libexec/**",
            "%{rocm_root}/lib/llvm/include/**",
            "%{rocm_root}/lib/rocm_sysdeps/share/terminfo/**",
        ],
    ),
    visibility = ["//visibility:public"],
)

config_setting(
    name = "using_hipcc",
    define_values = {
        "using_rocm": "true",
    },
    visibility = ["//visibility:public"],
)

# ROCm distribution's clang compiler (single file for use in attributes)
filegroup(
    name = "clang",
    srcs = glob(
        ["%{rocm_root}/llvm/bin/clang"],
        exclude = ["%{rocm_root}/llvm/bin/clang-*"],
    ),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "clang++",
    srcs = glob(["%{rocm_root}/llvm/bin/clang++"]),
    visibility = ["//visibility:public"],
)

# All clang binaries (for packaging)
filegroup(
    name = "clang_all",
    srcs = glob([
        "%{rocm_root}/llvm/bin/clang",
        "%{rocm_root}/llvm/bin/clang-*",
    ]),
    visibility = ["//visibility:public"],
)

# ROCm LLVM linker
filegroup(
    name = "ld",
    srcs = glob(["%{rocm_root}/llvm/bin/ld.lld"]),
    visibility = ["//visibility:public"],
)

# ROCm LLVM archiver
filegroup(
    name = "ar",
    srcs = glob(["%{rocm_root}/llvm/bin/llvm-ar"]),
    visibility = ["//visibility:public"],
)

# ROCm LLVM strip
filegroup(
    name = "strip",
    srcs = glob(["%{rocm_root}/llvm/bin/llvm-strip"]),
    visibility = ["//visibility:public"],
)

# ROCm LLVM compiler includes (raw filegroup)
filegroup(
    name = "compiler_incs_files",
    srcs = glob(["%{rocm_root}/llvm/lib/clang/*/include/**"]),
)

# Wrapped for cc_toolchain_import
cc_toolchain_import(
    name = "compiler_incs",
    hdrs = [":compiler_incs_files"],
    includes = glob(["%{rocm_root}/llvm/lib/clang/*/include"], exclude_directories = 0),
    visibility = ["//visibility:public"],
)

# ROCm llvm-symbolizer for sanitizer stack trace symbolization
filegroup(
    name = "llvm-symbolizer",
    srcs = glob(["%{rocm_root}/llvm/bin/llvm-symbolizer"]),
    visibility = ["//visibility:public"],
)

# Distribution libraries needed by llvm-symbolizer
filegroup(
    name = "distro_libs",
    srcs = glob(["%{rocm_root}/llvm/lib/*.so*"]),
    visibility = ["//visibility:public"],
)


