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

GCC_VERSION = 7
GLIBC_VERSION = "2.27"

CRT_OBJECTS = [
    "crti",
    "crtn",
    # Use PIC Scrt1.o instead of crt1.o to keep PIC code from segfaulting.
    "Scrt1",
]

[
    cc_toolchain_import(
        name = obj,
        static_library = "usr/lib/aarch64-linux-gnu/%s.o" % obj,
    )
    for obj in CRT_OBJECTS
]

cc_toolchain_import(
    name = "startup_libs",
    #target_compatible_with = select({
    #    "@platforms//os:linux": ["@platforms//cpu:aarch64"],
    #    "//conditions:default": ["@platforms//:incompatible"],
    #}),
    visibility = ["//visibility:public"],
    deps = [":" + obj for obj in CRT_OBJECTS],
)

cc_toolchain_import(
    name = "includes_c",
    hdrs = glob([
        "usr/include/c++/*/**",
        "usr/include/aarch64-linux-gnu/c++/*/**",
        "usr/include/c++/7/experimental/**",
    ]),
    includes = [
        "usr/include/c++/7",
        "usr/include/aarch64-linux-gnu/c++/7",
        "usr/include/c++/7/backward",
        "usr/include/c++/7/experimental",
    ],
    #target_compatible_with = select({
    #    "@platforms//os:linux": ["@platforms//cpu:aarch64"],
    #    "//conditions:default": ["@platforms//:incompatible"],
    #}),
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "includes_system",
    hdrs = glob([
        "usr/local/include/**",
        "usr/include/aarch64-linux-gnu/**",
        "usr/include/**",
    ]),
    includes = [
        "usr/local/include",
        "usr/include/aarch64-linux-gnu",
        "usr/include",
    ],
    #target_compatible_with = select({
    #    "@platforms//os:linux": ["@platforms//cpu:aarch64"],
    #    "//conditions:default": ["@platforms//:incompatible"],
    #}),
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "gcc",
    additional_libs = [
        "lib/aarch64-linux-gnu/libgcc_s.so.1",
        "usr/lib/gcc/aarch64-linux-gnu/{gcc_version}/libgcc_eh.a".format(gcc_version = GCC_VERSION),
    ],
    runtime_path = "/usr/lib/aarch64-linux-gnu",
    shared_library = "usr/lib/gcc/aarch64-linux-gnu/{gcc_version}/libgcc_s.so".format(gcc_version = GCC_VERSION),
    static_library = "usr/lib/gcc/aarch64-linux-gnu/{gcc_version}/libgcc.a".format(gcc_version = GCC_VERSION),
    #target_compatible_with = select({
    #    "@platforms//os:linux": ["@platforms//cpu:aarch64"],
    #    "//conditions:default": ["@platforms//:incompatible"],
    #}),
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "stdc++",
    additional_libs = [
        "usr/lib/aarch64-linux-gnu/libstdc++.so.6",
        "usr/lib/aarch64-linux-gnu/libstdc++.so.6.0.25",
    ],
    shared_library = "usr/lib/gcc/aarch64-linux-gnu/{gcc_version}/libstdc++.so".format(gcc_version = GCC_VERSION),
    static_library = "usr/lib/gcc/aarch64-linux-gnu/{gcc_version}/libstdc++.a".format(gcc_version = GCC_VERSION),
    #target_compatible_with = select({
    #    "@platforms//os:linux": ["@platforms//cpu:aarch64"],
    #    "//conditions:default": ["@platforms//:incompatible"],
    #}),
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "dynamic_linker",
    additional_libs = [
        "lib/aarch64-linux-gnu/ld-linux-aarch64.so.1",
    ],
    runtime_path = "/lib64",
    shared_library = "usr/lib/aarch64-linux-gnu/libdl.so",
    static_library = "usr/lib/aarch64-linux-gnu/libdl.a",
    #target_compatible_with = select({
    #    "@platforms//os:linux": ["@platforms//cpu:aarch64"],
    #    "//conditions:default": ["@platforms//:incompatible"],
    #}),
    deps = [":libc"],
)

cc_toolchain_import(
    name = "math",
    additional_libs = ["lib/aarch64-linux-gnu/libm.so.6"],
    shared_library = "usr/lib/aarch64-linux-gnu/libm.so",
    static_library = "usr/lib/aarch64-linux-gnu/libm.a",
    #target_compatible_with = select({
    #    "@platforms//os:linux": ["@platforms//cpu:aarch64"],
    #    "//conditions:default": ["@platforms//:incompatible"],
    #}),
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "pthread",
    additional_libs = [
        "lib/aarch64-linux-gnu/libpthread.so.0",
        "lib/aarch64-linux-gnu/libpthread-{glibc_version}.so".format(glibc_version = GLIBC_VERSION),
        "usr/lib/aarch64-linux-gnu/libpthread_nonshared.a",
    ],
    shared_library = "usr/lib/aarch64-linux-gnu/libpthread.so",
    static_library = "usr/lib/aarch64-linux-gnu/libpthread.a",
    #target_compatible_with = select({
    #    "@platforms//os:linux": ["@platforms//cpu:aarch64"],
    #    "//conditions:default": ["@platforms//:incompatible"],
    #}),
    visibility = ["//visibility:public"],
    deps = [
        ":libc",
    ],
)

cc_toolchain_import(
    name = "libc",
    additional_libs = [
        "lib/aarch64-linux-gnu/libc.so.6",
        "usr/lib/aarch64-linux-gnu/libc_nonshared.a",
    ],
    runtime_path = "/usr/lib/gcc/aarch64-linux-gnu/{gcc_version}".format(gcc_version = GCC_VERSION),
    shared_library = "usr/lib/aarch64-linux-gnu/libc.so",
    static_library = "usr/lib/aarch64-linux-gnu/libc.a",
    #target_compatible_with = select({
    #    "@platforms//os:linux": ["@platforms//cpu:aarch64"],
    #    "//conditions:default": ["@platforms//:incompatible"],
    #}),
    visibility = ["//visibility:public"],
    deps = [
        ":gcc",
        ":math",
        ":stdc++",
    ],
)

# This is a group of all the system libraries we need. The actual glibc library is split
# out to fix link ordering problems that cause false undefined symbol positives.
cc_toolchain_import(
    name = "glibc",
    runtime_path = "/lib/aarch64-linux-gnu",
    #target_compatible_with = select({
    #    "@platforms//os:linux": ["@platforms//cpu:aarch64"],
    #    "//conditions:default": ["@platforms//:incompatible"],
    #}),
    visibility = ["//visibility:public"],
    deps = [
        ":dynamic_linker",
        ":libc",
    ],
)
