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

# ==============================================================================
# Fortran Tools: Linux aarch64, Sysroot: Linux aarch64
# ==============================================================================

load("//fortran:toolchain.bzl", "fortran_toolchain")
load("//fortran/features:features.bzl", "fortran_toolchain_import_feature")
load("//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl", "cc_toolchain_import")

package(
    default_visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "imports",
    deps = [
        "@llvm_linux_aarch64//:compiler_incs",
        "@sysroot_linux_aarch64//:sys_incs",
    ],
)

fortran_toolchain_import_feature(
    name = "imports_feature",
    enabled = True,
    flang_incs = "@llvm_linux_aarch64//:flang_incs",
    toolchain_import = ":imports",
)

filegroup(
    name = "compiler",
    srcs = [
        ":imports",
        "@llvm_linux_aarch64//:distro_libs",
        "@llvm_linux_aarch64//:flang",
        "@llvm_linux_aarch64//:flang_incs",
    ],
)

fortran_toolchain(
    name = "toolchain",
    compiler_features = [
        "//fortran/features:hermetic",
        ":imports_feature",
        "//fortran/features:warnings",
        "//fortran/features:errors",
        "//fortran/features:reproducible",
        "//fortran/features:use_lld",
        "//fortran/features:position_independent_code",
        "//fortran/features:garbage_collect_symbols",
        "//fortran/features:dbg",
        "//fortran/features:fastbuild",
        "//fortran/features:opt",
        "//fortran/features/linux/aarch64:sysroot",
    ],
    compiler_files = ":compiler",
    flang = "@llvm_linux_aarch64//:flang",
    flang_incs = "@llvm_linux_aarch64//:flang_incs",
    fortran_libs = "@llvm_linux_aarch64//:fortran_libs",
    fortran_main = "@llvm_linux_aarch64//:fortran_main",
    sysroot = "@sysroot_linux_aarch64//:sysroot",
    target = "aarch64-linux-gnu",
    target_cpu = "aarch64",
    toolchain_identifier = "fortran_toolchain_linux_aarch64_linux_aarch64_id",
)
