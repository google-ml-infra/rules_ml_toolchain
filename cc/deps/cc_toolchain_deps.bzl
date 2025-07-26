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

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("llvm_http_archive.bzl", "llvm_http_archive")

def cc_toolchain_deps():
    if "sysroot_linux_x86_64" not in native.existing_rules():
        # Produce wheels with tag manylinux_2_27_x86_64
        http_archive(
            name = "sysroot_linux_x86_64",
            sha256 = "02f418783479fbf612701e20ff9f48c1713b60545ec090da3855e77b9e27881a",
            urls = ["https://storage.googleapis.com/ml-sysroot-testing/ubuntu18_x86_64_sysroot_gcc8_patched.tar.xz"],
            build_file = Label("//cc/config:sysroot_ubuntu18_x86_64.BUILD"),
            strip_prefix = "ubuntu18_x86_64_sysroot_gcc8_patched",
        )

    if "sysroot_linux_aarch64" not in native.existing_rules():
        http_archive(
            name = "sysroot_linux_aarch64",
            sha256 = "d883a1d664500f11bb49aa70c650a9e68d49341324c447f9abda77ec2f335ac5",
            urls = ["https://storage.googleapis.com/ml-sysroot-testing/ubuntu18_aarch64-sysroot.tar.xz"],
            build_file = Label("//cc/config:sysroot_ubuntu18_aarch64.BUILD"),
            strip_prefix = "ubuntu18_aarch64-sysroot",
        )

    if "sysroot_darwin_aarch64" not in native.existing_rules():
        native.new_local_repository(
            name = "sysroot_darwin_aarch64",
            build_file = "//cc/config:sysroot_darwin_aarch64.BUILD",
            path = "cc/sysroots/darwin_aarch64/MacOSX.sdk",
        )

    if "llvm_linux_x86_64" not in native.existing_rules():
        llvm_http_archive(
            name = "llvm_linux_x86_64",
            urls = ["https://github.com/llvm/llvm-project/releases/download/llvmorg-18.1.8/clang+llvm-18.1.8-x86_64-linux-gnu-ubuntu-18.04.tar.xz"],
            sha256 = "54ec30358afcc9fb8aa74307db3046f5187f9fb89fb37064cdde906e062ebf36",
            build_file = Label("//cc/config:llvm18_linux_x86_64.BUILD"),
            strip_prefix = "clang+llvm-18.1.8-x86_64-linux-gnu-ubuntu-18.04",
            remote_file_urls = {
                "lib/libtinfo.so.5": ["https://github.com/yuriit-google/sysroots/raw/f890514a360cd1959c786402a8e794218b1be93f/archives/libtinfo.so.5"],
                "lib/libtinfo5-copyright.txt": ["https://raw.githubusercontent.com/yuriit-google/sysroots/ba192c408e0f82c6c9a5b92712038edaa64326d6/archives/copyright"],
            },
            remote_file_integrity = {
                "lib/libtinfo.so.5": "sha256-Es/8cnQZDKFpOlLM2DA+cZQH5wfIVX3ft+74HyCO+qs=",
                "lib/libtinfo5-copyright.txt": "sha256-Xo7pAsiQbdt3ef023Jl5ywi1H76/fAsamut4rzgq9ZA=",
            },
        )

    # LLVM 19
    #if "llvm_linux_x86_64" not in native.existing_rules():
    #    llvm_http_archive(
    #        name = "llvm_linux_x86_64",
    #        urls = ["https://github.com/llvm/llvm-project/releases/download/llvmorg-19.1.7/LLVM-19.1.7-Linux-X64.tar.xz"],
    #        sha256 = "4a5ec53951a584ed36f80240f6fbf8fdd46b4cf6c7ee87cc2d5018dc37caf679",
    #        build_file = Label("//cc/config:llvm19_linux_x86_64.BUILD"),
    #        strip_prefix = "LLVM-19.1.7-Linux-X64",
    #    )

    if "llvm_darwin_aarch64" not in native.existing_rules():
        llvm_http_archive(
            name = "llvm_darwin_aarch64",
            urls = ["https://github.com/llvm/llvm-project/releases/download/llvmorg-18.1.8/clang+llvm-18.1.8-arm64-apple-macos11.tar.xz"],
            sha256 = "4573b7f25f46d2a9c8882993f091c52f416c83271db6f5b213c93f0bd0346a10",
            build_file = Label("//cc/config:llvm18_darwin_aarch64.BUILD"),
            strip_prefix = "clang+llvm-18.1.8-arm64-apple-macos11",
        )
