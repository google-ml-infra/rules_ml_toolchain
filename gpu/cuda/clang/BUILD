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
    "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl",
    "cc_toolchain_import",
)

cc_toolchain_import(
    name = "inject_cuda_runtime_wrapper",
    hdrs = [
        "clang_cuda_runtime_wrapper.h",
    ],
    injected_hdrs = [
        "clang_cuda_runtime_wrapper.h",
    ],
    target_compatible_with = select({
        "@platforms//os:linux": [],
        "@platforms//os:macos": [],
    }),
    visibility = ["//visibility:public"],
)
