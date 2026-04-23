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

load("@config_rocm_hipcc//rocm:build_defs.bzl", "hipcc_config")
load("//cc/rocm:rocm_flags_provider.bzl", "rocm_flags")

package(default_visibility = ["//visibility:public"])

exports_files(["rocm_compile.bzl"])

# Aggregate ROCm compiler flags from all toolchain features
rocm_flags(
    name = "rocm_flags",
    amdgpu_targets = hipcc_config().gpu_architectures,
)
