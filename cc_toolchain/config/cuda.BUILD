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

load(
    "@rules_ml_toolchain//cc_toolchain:cuda.bzl",
    "cuda_package",
)
load(
    "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl",
    "cc_toolchain_import",
)

filegroup(
    name = "all",
    srcs = glob(["cuda_nvcc/**/*"]),
    visibility = ["//visibility:public"],
)

cuda_package(
    name = "cuda",
    nvcc_path = "cuda_nvcc",
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "cudart",
    hdrs = glob([
        "cuda_cudart/include/**",
    ]),
    includes = [
        "cuda_cudart/include",
    ],
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "nvcc",
    hdrs = glob([
        "cuda_nvcc/include/**",
    ]),
    includes = [
        "cuda_nvcc/include",
    ],
    additional_libs = [
        "cuda_nvcc/nvvm/libdevice/libdevice.10.bc",
    ],
    visibility = ["//visibility:public"],
)
