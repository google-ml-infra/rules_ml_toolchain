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
load("//cc/deps:llvm_http_archive.bzl", "llvm_http_archive")
load("//common:mirrored_http_archive.bzl", "mirrored_http_archive")
load("//third_party:repo.bzl", "tf_mirror_urls")

# DEPRECATED FUNCTION, USE //cc/deps:cc_toolchain_deps.bzl INSTEAD
def cc_toolchain_deps():
    if "sysroot_linux_x86_64" not in native.existing_rules():
        # Produce wheels with tag manylinux_2_27_x86_64
        mirrored_http_archive(
            name = "sysroot_linux_x86_64",
            sha256 = "02f418783479fbf612701e20ff9f48c1713b60545ec090da3855e77b9e27881a",
            urls = tf_mirror_urls("https://storage.googleapis.com/ml-sysroot-testing/ubuntu18_x86_64_sysroot_gcc8_patched.tar.xz"),
            build_file = Label("//cc/config:sysroot_ubuntu18_x86_64.BUILD"),
            strip_prefix = "ubuntu18_x86_64_sysroot_gcc8_patched",
        )

    if "llvm_linux_x86_64" not in native.existing_rules():
        llvm_http_archive(
            name = "llvm_linux_x86_64",
            urls = tf_mirror_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-18.1.8/clang+llvm-18.1.8-x86_64-linux-gnu-ubuntu-18.04.tar.xz"),
            sha256 = "54ec30358afcc9fb8aa74307db3046f5187f9fb89fb37064cdde906e062ebf36",
            mirrored_tar_sha256 = "01b8e95e34e7d0117edd085577529b375ec422130ed212d2911727545314e6c2",
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
