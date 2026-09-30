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
# Fortran Tools: Linux x86_64, Sysroot: Linux x86_64
# ==============================================================================

load("//fortran:toolchain.bzl", "fortran_toolchain")

package(
    default_visibility = ["//visibility:public"],
)

filegroup(
    name = "compiler",
    srcs = [
        "@llvm_linux_x86_64//:compiler_incs",
        "@llvm_linux_x86_64//:distro_libs",
        "@llvm_linux_x86_64//:flang",
        "@llvm_linux_x86_64//:flang_incs",
        "@sysroot_linux_x86_64//:sys_incs",
    ],
)

fortran_toolchain(
    name = "toolchain",
    compiler_files = ":compiler",
    flang = "@llvm_linux_x86_64//:flang",
    flang_incs = "@llvm_linux_x86_64//:flang_incs",
    fortran_libs = "@llvm_linux_x86_64//:fortran_libs",
    fortran_main = "@llvm_linux_x86_64//:fortran_main",
    sysroot = "@sysroot_linux_x86_64//:sysroot",
    target = "x86_64-linux-gnu",
    target_cpu = "x86_64",
    toolchain_identifier = "fortran_toolchain_linux_x86_64_linux_x86_64_id",
)
