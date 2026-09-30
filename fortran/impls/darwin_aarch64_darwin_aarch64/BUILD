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
# Fortran Tools: macOS aarch64, Sysroot: macOS aarch64
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
        "@llvm_darwin_aarch64//:compiler_incs",
        "@sysroot_darwin_aarch64//:sys_incs",
    ],
)

fortran_toolchain_import_feature(
    name = "imports_feature",
    enabled = True,
    flang_incs = "@llvm_darwin_aarch64//:flang_incs",
    toolchain_import = ":imports",
)

filegroup(
    name = "compiler",
    srcs = [
        ":imports",
        "@llvm_darwin_aarch64//:distro_libs",
        "@llvm_darwin_aarch64//:flang",
        "@llvm_darwin_aarch64//:flang_incs",
    ],
)

fortran_toolchain(
    name = "toolchain",
    compiler_features = [
        "//fortran/features:hermetic",
        ":imports_feature",
        "//fortran/features:undefined_symbols",
        "//fortran/features:warnings",
        "//fortran/features:errors",
        "//fortran/features:reproducible",
        "//fortran/features:use_lld",
        "//fortran/features:max_install_names",
        "//fortran/features:position_independent_code",
        "//fortran/features:dbg",
        "//fortran/features:fastbuild",
        "//fortran/features:opt",
        "//fortran/features/darwin/aarch64:sysroot",
    ],
    compiler_files = ":compiler",
    flang = "@llvm_darwin_aarch64//:flang",
    flang_incs = "@llvm_darwin_aarch64//:flang_incs",
    fortran_libs = "@llvm_darwin_aarch64//:fortran_libs",
    fortran_main = "@llvm_darwin_aarch64//:fortran_main",
    sysroot = "@sysroot_darwin_aarch64//:sysroot",
    # Use the lowest macOS arm64 version supported by LLVM 22 for maximal compatibility
    # Use flag --macos_minimum_os for overriding this.
    target = "arm64-apple-macosx11.0",
    target_cpu = "aarch64",
    toolchain_identifier = "fortran_toolchain_darwin_aarch64_darwin_aarch64_id",
)
