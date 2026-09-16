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

load("@rules_cc//cc:defs.bzl", "cc_library")
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
    name = "std_incs",
    hdrs = glob([
        "usr/include/c++/v1/**",
    ]),
    includes = [
        "usr/include/c++/v1",
    ],
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "sys_incs",
    hdrs = glob([
            "usr/include/**",
            "System/Library/Frameworks/CoreFoundation/**",  # Include created symbolic link directory
            "System/Library/Frameworks/CoreFoundation.framework/**",
        ],
        allow_empty = True,
    ),
    includes = [
        "usr/include",
        "System/Library/Frameworks",
    ],
    frameworks = [
        "System/Library/Frameworks",
    ],
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
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "libm",
    # libSystem.tbd exists as separate "system" target
    #additional_libs = [
    #    "usr/lib/libSystem.tbd",
    #],
    shared_library = "usr/lib/libm.tbd",
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "libstdc++",
    additional_libs = [
        "usr/lib/libc++.1.tbd",
    ],
    shared_library = "usr/lib/libc++.tbd",
    visibility = ["//visibility:public"],
)

# Redundancy library (for configuration compatibility with Linux system)
cc_toolchain_import(
    name = "libpthread",
    # libSystem.tbd exists as separate "system" target
    #additional_libs = [
    #    "usr/lib/libSystem.tbd",
    #],
    shared_library = "usr/lib/libpthread.tbd",
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "objc",
    additional_libs = [
        "usr/lib/libobjc.A.tbd",
    ],
    shared_library = "usr/lib/libobjc.tbd",
)

cc_toolchain_import(
    name = "core_foundation",
    additional_libs = [
        "System/Library/Frameworks/CoreFoundation.framework/Versions/Current/CoreFoundation.tbd",
    ],
    shared_library = "System/Library/Frameworks/CoreFoundation.framework/CoreFoundation.tbd",
)

# This is a group of essential system libraries. The actual syslibs library is split
# out to fix link ordering problems that cause false undefined symbol positives.
cc_toolchain_import(
    name = "sys_libs",
    visibility = ["//visibility:public"],
    deps = [
        ":system",
        ":libm",
        ":libstdc++",
        ":libpthread",
        ":objc",
        ":core_foundation",
    ],
)

#============================================================================================
# Extra libraries
#============================================================================================
cc_library(
    name = "openmp_import",
    visibility = ["//visibility:public"],
)

filegroup(
    name = "openmp_copyright",
    srcs = [],
    visibility = ["//visibility:public"],
)
