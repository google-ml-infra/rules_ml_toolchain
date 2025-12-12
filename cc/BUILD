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

load("@rules_cc//cc:defs.bzl", "cc_toolchain")
load("//third_party/rules_cc_toolchain:toolchain_config.bzl", "cc_toolchain_config")
load("//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl", "cc_toolchain_import")

package(
    default_visibility = ["//visibility:public"],
)

#=====================================================================
# Executor platform: Linux x86_64
#=====================================================================

# Target platform: Linux x86_64, Essential (Default) toolchain
toolchain(
    name = "linux_x86_64_linux_x86_64",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    target_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    target_settings = [
        "//common:is_cuda_disabled",
        "//common:is_sycl_disabled",
        "//common:is_hermetic_cc_enabled",
    ],
    toolchain = "//cc/impls/linux_x86_64_linux_x86_64:toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)

# Target platform: Linux x86_64, CUDA
toolchain(
    name = "linux_x86_64_linux_x86_64_cuda",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    target_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    target_settings = [
        "//common:is_cuda_enabled",
        "//common:is_sycl_disabled",
        "//common:is_hermetic_cc_enabled",
    ],
    toolchain = "//cc/impls/linux_x86_64_linux_x86_64_cuda:toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)

# Target platform: Linux aarch64
toolchain(
    name = "linux_x86_64_linux_aarch64",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    target_compatible_with = [
        "@platforms//cpu:aarch64",
        "@platforms//os:linux",
    ],
    target_settings = [
        "//common:is_cuda_disabled",
        "//common:is_sycl_disabled",
        "//common:is_hermetic_cc_enabled",
    ],
    toolchain = "//cc/impls/linux_x86_64_linux_aarch64:toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)

# Target platform: Darwin aarch64
toolchain(
    name = "linux_x86_64_darwin_aarch64",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    target_compatible_with = [
        "@platforms//cpu:aarch64",
        "@platforms//os:macos",
    ],
    target_settings = [
        "//common:is_cuda_disabled",
        "//common:is_sycl_disabled",
        "//common:is_hermetic_cc_enabled",
    ],
    toolchain = "//cc/impls/linux_x86_64_darwin_aarch64:toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)

# Target platform: Linux x86_64, SYCL
toolchain(
    name = "linux_x86_64_linux_x86_64_sycl",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    target_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    target_settings = [
        "//common:is_cuda_disabled",
        "//common:is_sycl_enabled",
        "//common:is_hermetic_cc_enabled",
    ],
    toolchain = "//cc/impls/linux_x86_64_linux_x86_64_sycl:toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)

#=====================================================================
# Executor platform: aarch64
#=====================================================================

# Target platform: Linux aarch64, Essential (Default) toolchain
toolchain(
    name = "linux_aarch64_linux_aarch64",
    exec_compatible_with = [
        "@platforms//cpu:aarch64",
        "@platforms//os:linux",
    ],
    target_compatible_with = [
        "@platforms//cpu:aarch64",
        "@platforms//os:linux",
    ],
    target_settings = [
        "//common:is_cuda_disabled",
        "//common:is_sycl_disabled",
        "//common:is_hermetic_cc_enabled",
    ],
    toolchain = "//cc/impls/linux_aarch64_linux_aarch64:toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)

# Target platform: Linux aarch64, CUDA
toolchain(
    name = "linux_aarch64_linux_aarch64_cuda",
    exec_compatible_with = [
        "@platforms//cpu:aarch64",
        "@platforms//os:linux",
    ],
    target_compatible_with = [
        "@platforms//cpu:aarch64",
        "@platforms//os:linux",
    ],
    target_settings = [
        "//common:is_cuda_enabled",
        "//common:is_sycl_disabled",
        "//common:is_hermetic_cc_enabled",
    ],
    toolchain = "//cc/impls/linux_aarch64_linux_aarch64_cuda:toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)

#=====================================================================
# Executor platform: macOS aarch64
#=====================================================================

# Target platform: macOS aarch64
# buildifier: leave-alone
toolchain(
    name = "darwin_aarch64_darwin_aarch64",
    exec_compatible_with = [
        "@platforms//cpu:aarch64",
        "@platforms//os:macos",
    ],
    target_compatible_with = [
        "@platforms//cpu:aarch64",
        "@platforms//os:macos",
    ],
    target_settings = [
        "//common:is_cuda_disabled",
        "//common:is_sycl_disabled",
        "//common:is_hermetic_cc_enabled",
    ],
    toolchain = "//cc/impls/darwin_aarch64_darwin_aarch64:toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)
