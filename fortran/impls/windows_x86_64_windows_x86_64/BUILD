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
# Fortran Tools: Windows x86_64 (MSVC), Target: Windows x86_64 (MSVC)
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
        "@llvm_windows_x86_64//:compiler_incs",
    ],
)

fortran_toolchain_import_feature(
    name = "imports_feature",
    enabled = True,
    flang_incs = "@llvm_windows_x86_64//:flang_incs",
    toolchain_import = ":imports",
)

filegroup(
    name = "compiler",
    srcs = [
        ":imports",
        "@llvm_windows_x86_64//:ar",
        "@llvm_windows_x86_64//:clang++",
        "@llvm_windows_x86_64//:distro_libs",
        "@llvm_windows_x86_64//:flang",
        "@llvm_windows_x86_64//:flang_incs",
        "@llvm_windows_x86_64//:lld",
    ],
)

fortran_toolchain(
    name = "toolchain",
    archiver = "@llvm_windows_x86_64//:ar",
    compiler_features = [
        ":imports_feature",
        "//fortran/features:warnings",
        "//fortran/features:errors",
        "//fortran/features:reproducible",
        "//fortran/features:dbg",
        "//fortran/features:fastbuild",
        "//fortran/features:opt",
        "//fortran/features/windows/x86_64:sysroot",
        "//fortran/features:use_lld",
    ],
    compiler_files = ":compiler",
    flang = "@llvm_windows_x86_64//:flang",
    flang_incs = "@llvm_windows_x86_64//:flang_incs",
    fortran_libs = "@llvm_windows_x86_64//:fortran_libs",
    fortran_main = "@llvm_windows_x86_64//:fortran_main",
    linker = "@llvm_windows_x86_64//:flang",
    target = "x86_64-pc-windows-msvc",
    target_cpu = "x86_64",
    toolchain_identifier = "fortran_toolchain_windows_x86_64_windows_x86_64_id",
)
