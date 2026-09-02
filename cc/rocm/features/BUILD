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

"""ROCm-specific toolchain features."""

load(
    "//third_party/rules_cc_toolchain/features:features.bzl",
    "cc_feature",
)
load(":rocm_global_symbol_version_script_feature.bzl", "rocm_global_symbol_version_script_feature")

package(default_visibility = ["//visibility:public"])

config_setting(
    name = "is_rocm_global_symbol_version_enabled",
    flag_values = {
        "//common:enable_rocm_global_symbol_version": "True",
    },
)

filegroup(
    name = "global_symbol_version_script",
    srcs = ["global_symbol_version.lds"],
)

# ROCm-specific preprocessor definitions
cc_feature(
    name = "rocm_defines",
    compiler_flags = [
        "-DTENSORFLOW_USE_ROCM=1",
        "-D__HIP_PLATFORM_AMD__",
        "-DEIGEN_USE_HIP",
        "-DUSE_ROCM",
    ],
    enabled = True,
)

# Hermetic ROCm includes - prevents using system HIP headers
cc_feature(
    name = "rocm_hermetic",
    compiler_flags = ["-nohipinc"],
    enabled = True,
)

# Warning settings specific to ROCm compilation
cc_feature(
    name = "rocm_warnings",
    compiler_flags = [
        "-Wno-unused-result",
    ],
    enabled = True,
)

# Use compiler-rt runtime library instead of libgcc
# This is required for ROCm/HIP compilation to properly link
# with the LLVM compiler-rt builtins
cc_feature(
    name = "rocm_compiler_rt",
    compiler_flags = ["-rtlib=compiler-rt"],
    enabled = True,
    linker_flags = ["-rtlib=compiler-rt"],
)

# ROCm global symbol versioning
# Controls symbol visibility using a linker version script
# Can be enabled with --@rules_ml_toolchain//common:enable_rocm_global_symbol_version=True
rocm_global_symbol_version_script_feature(
    name = "rocm_global_symbol_version_script",
    enabled = select({
        "//cc/rocm/features:is_rocm_global_symbol_version_enabled": True,
        "//conditions:default": False,
    }),
    version_script = ":global_symbol_version_script",
    visibility = ["//visibility:public"],
)
