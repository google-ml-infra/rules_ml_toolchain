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
    "@rules_ml_toolchain//third_party/rules_cc_toolchain:sysroot.bzl",
    "sysroot_package",
)
load(
    "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl",
    "cc_toolchain_import",
)

sysroot_package(
    name = "sysroot",
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "includes_c",
    hdrs = glob([
        "usr/include/c++/v1/**",
    ]),
    includes = [
        "usr/include/c++/v1",
    ],
    #target_compatible_with = select({
    #    "@platforms//os:macos": ["@platforms//cpu:aarch64"],
    #    "//conditions:default": ["@platforms//:incompatible"],
    #}),
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "includes_system",
    hdrs = glob([
        "usr/include/**",
        "System/Library/Frameworks/CoreFoundation/**",  # Include created symbolic link directory
        "System/Library/Frameworks/CoreFoundation.framework/**",
    ]),
    includes = [
        "usr/include",
        "System/Library/Frameworks",
    ],
    frameworks = [
        "System/Library/Frameworks",
    ],
    #target_compatible_with = select({
    #    "@platforms//os:macos": ["@platforms//cpu:aarch64"],
    #    "//conditions:default": ["@platforms//:incompatible"],
    #}),
    visibility = ["//visibility:public"],
)

# In Darwin, much is built into the system library, /usr/lib/libSystem.tbd.
# In particular, the following libraries are included in libSystem:
#   * libinfo - NetInfo library
#   * libm - math library, which contains arithmetic functions
#   * libpthread - POSIX threads library, which allows multiple tasks to run concurrently
cc_toolchain_import(
    name = "system",
    shared_library = "usr/lib/libSystem.tbd",
    #target_compatible_with = select({
    #    "@platforms//os:macos": ["@platforms//cpu:aarch64"],
    #    "//conditions:default": ["@platforms//:incompatible"],
    #}),
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "libm",
    shared_library = "usr/lib/libm.tbd",
    #target_compatible_with = select({
    #    "@platforms//os:macos": ["@platforms//cpu:aarch64"],
    #    "//conditions:default": ["@platforms//:incompatible"],
    #}),
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "stdc++",
    shared_library = "usr/lib/libc++.tbd",
    #target_compatible_with = select({
    #    "@platforms//os:macos": ["@platforms//cpu:aarch64"],
    #    "//conditions:default": ["@platforms//:incompatible"],
    #}),
    visibility = ["//visibility:public"],
)

# Redundancy library (for configuration compatibility with Linux system)
cc_toolchain_import(
    name = "pthread",
    shared_library = "usr/lib/libpthread.tbd",
    #target_compatible_with = select({
    #    "@platforms//os:macos": ["@platforms//cpu:aarch64"],
    #    "//conditions:default": ["@platforms//:incompatible"],
    #}),
    visibility = ["//visibility:public"],
    deps = [
        ":glibc",
    ],
)

cc_toolchain_import(
    name = "objc",
    shared_library = "usr/lib/libobjc.tbd",
    #target_compatible_with = select({
    #    "@platforms//os:macos": ["@platforms//cpu:aarch64"],
    #    "//conditions:default": ["@platforms//:incompatible"],
    #}),
)

cc_toolchain_import(
    name = "core_foundation",
    additional_libs = [
        "usr/lib/libobjc.A.tbd",
        "usr/lib/libobjc.tbd",
    ],
    shared_library = "System/Library/Frameworks/CoreFoundation.framework/CoreFoundation.tbd",
)

# This is a group of all the system libraries we need. The actual glibc library is split
# out to fix link ordering problems that cause false undefined symbol positives.
cc_toolchain_import(
    name = "glibc",
    #runtime_path = "usr/lib",
    #target_compatible_with = select({
    #    "@platforms//os:macos": ["@platforms//cpu:aarch64"],
    #    "//conditions:default": ["@platforms//:incompatible"],
    #}),
    visibility = ["//visibility:public"],
    deps = [
        ":system",
        ":libm",
        ":stdc++",
        ":objc",
        ":core_foundation",
    ],
)
