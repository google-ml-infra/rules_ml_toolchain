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

load("@bazel_skylib//rules:common_settings.bzl", "bool_flag")
load("//gpu/cuda:enable_cuda_flag.bzl", "enable_cuda_flag")

package(default_visibility = ["//visibility:public"])

#######################################################
# Platforms definition
platform(
    name = "linux_x86_64",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
)

platform(
    name = "linux_aarch64",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:aarch64",
    ],
)

platform(
    name = "macos_aarch64",
    constraint_values = [
        "@platforms//os:macos",
        "@platforms//cpu:aarch64",
    ],
)

#######################################################
# Enable Hermetic C++ support flags

bool_flag(
    name = "enable_hermetic_cc",
    build_setting_default = True,
)

config_setting(
    name = "is_hermetic_cc_enabled",
    flag_values = {
        ":enable_hermetic_cc": "True",
    },
)

#######################################################
# Enable CUDA support flags
#
# Enable with '--@local_config_cuda//:enable_cuda', or indirectly with
# ./configure or '--config=cuda'.
enable_cuda_flag(
    name = "enable_cuda",
    build_setting_default = False,
    enable_override = select({
        ":define_using_cuda_nvcc": True,
        "//conditions:default": False,
    }),
)

# Config setting to keep `--define=using_cuda_nvcc=true` working.
# TODO(b/174244321): Remove when downstream projects have been fixed, along
# with the enable_cuda_flag rule in cuda:build_defs.bzl.tpl.
config_setting(
    name = "define_using_cuda_nvcc",
    define_values = {"using_cuda_nvcc": "true"},
    visibility = ["//visibility:private"],
)

# Config setting whether CUDA support has been requested.
#
# Enable path: ./configure > --config=cuda (.tf_configure.bazelrc)
#     > --//tensorflow:enable_cuda (.bazelrc) > :is_cuda_enabled
config_setting(
    name = "is_cuda_enabled",
    flag_values = {":enable_cuda": "True"},
)

config_setting(
    name = "is_cuda_disabled",
    flag_values = {":enable_cuda": "False"},
)

#######################################################
# Enable SYCL support flags

bool_flag(
    name = "enable_sycl",
    build_setting_default = False,
)

config_setting(
    name = "is_sycl_enabled",
    flag_values = {
        ":enable_sycl": "True",
    },
)

config_setting(
    name = "is_sycl_disabled",
    flag_values = {
        ":enable_sycl": "False",
    },
)
