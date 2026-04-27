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
    hdrs = glob(["%{rocm_root}/include/**/*.h"]),
    includes = ["%{rocm_root}/include"],
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
        exclude = [
            "%{rocm_root}/**/libamdhip64.so.*.*.*",
        ]),
    visibility = ["//visibility:public"],
)

# ROCm's C++ runtime libraries for linking GPU kernel .so files
filegroup(
    name = "rocm_cxx_runtime",
    srcs = glob([
        "%{rocm_root}/llvm/lib/libc++.so*",
        "%{rocm_root}/llvm/lib/libc++abi.so*",
    ]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "rocm_redist",
    srcs = glob(["%{rocm_root}/**"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "toolchain_data",
    srcs = glob([
        "%{rocm_root}/bin/hipcc",
        "%{rocm_root}/lib/llvm/**",
        "%{rocm_root}/llvm/bin/*",
        "%{rocm_root}/lib/llvm/lib/clang/**/include/**",
        "%{rocm_root}/lib/llvm/lib/clang/**/lib/**/*.a",
        "%{rocm_root}/lib/llvm/lib/clang/**/lib/**/*.bc",
        "%{rocm_root}/llvm/lib/clang/*/include/**",
        "%{rocm_root}/share/hip/**",
        "%{rocm_root}/amdgcn/**",
        "%{rocm_root}/lib/rocm_sysdeps/lib/*.so*",
        "%{rocm_root}/llvm/lib/*.so*",
    ]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "all_files",
    srcs = glob(["%{rocm_root}/**"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "rocm_root",
    srcs = [":all_files"],
    visibility = ["//visibility:public"],
)

# Make hipcc available as an executable
sh_binary(
    name = "hipcc_bin",
    srcs = ["%{rocm_root}/bin/hipcc"],
    data = [":toolchain_data"],
    visibility = ["//visibility:public"],
)

# Aliases for individual tools (used by cc_toolchain_config and rocm_compile)
alias(
    name = "hipcc",
    actual = "%{rocm_root}/bin/hipcc",
    visibility = ["//visibility:public"],
)

alias(
    name = "ld.lld",
    actual = "%{rocm_root}/llvm/bin/ld.lld",
    visibility = ["//visibility:public"],
)

alias(
    name = "llvm-ar",
    actual = "%{rocm_root}/llvm/bin/llvm-ar",
    visibility = ["//visibility:public"],
)

alias(
    name = "llvm-strip",
    actual = "%{rocm_root}/llvm/bin/llvm-strip",
    visibility = ["//visibility:public"],
)

alias(
    name = "llvm-nm",
    actual = "%{rocm_root}/llvm/bin/llvm-nm",
    visibility = ["//visibility:public"],
)

alias(
    name = "llvm-objdump",
    actual = "%{rocm_root}/llvm/bin/llvm-objdump",
    visibility = ["//visibility:public"],
)

# Individual tool targets for cc_toolchain_config
exports_files(
    [
        "%{rocm_root}/bin/hipcc",
        "%{rocm_root}/llvm/bin/ld.lld",
        "%{rocm_root}/llvm/bin/llvm-ar",
        "%{rocm_root}/llvm/bin/llvm-strip",
        "%{rocm_root}/llvm/bin/llvm-nm",
        "%{rocm_root}/llvm/bin/llvm-objdump",
    ],
    visibility = ["//visibility:public"],
)

config_setting(
    name = "using_hipcc",
    define_values = {
        "using_rocm": "true",
    },
    visibility = ["//visibility:public"],
)
