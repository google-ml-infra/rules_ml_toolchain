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
load(
    "//cc/rocm/features:rocm_runtime_library_search_directories.bzl",
    "rocm_runtime_library_search_directories",
)

package(default_visibility = ["//visibility:public"])

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

# Strip solib rpaths for ROCm wheel builds
# This feature is always enabled for ROCm builds to ensure wheel portability
# It prevents Bazel from adding _solib_* and .runfiles paths to the RUNPATH
# IMPORTANT: This must be named "no_solib_rpaths" to match the not_features
# condition in toolchain_config.bzl
cc_feature(
    name = "no_solib_rpaths",
    enabled = True,
)

# ROCm-specific runtime_library_search_directories feature
# This overrides the default action_config-embedded flag_sets to ensure
# proper with_features support for no_solib_rpaths
rocm_runtime_library_search_directories(
    name = "rocm_runtime_library_search_directories",
)
