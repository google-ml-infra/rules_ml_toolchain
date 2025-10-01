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
load("@bazel_tools//tools/build_defs/repo:local.bzl", "new_local_repository")
load("//common:mirrored_http_archive.bzl", "mirrored_http_archive")
load("//third_party:repo.bzl", "tf_mirror_urls")
load("llvm_http_archive.bzl", "llvm_http_archive")

def cc_toolchain_deps():
    if "sysroot_linux_x86_64" not in native.existing_rules():
        # C++17, manylinux_2_27, gcc-8
        mirrored_http_archive(
            name = "sysroot_linux_x86_64",
            sha256 = "7d9300ec03d008e96f0098dfcd4e9974dd64f2d5fccdd0f1a2b2d4af63301a04",
            urls = tf_mirror_urls("https://storage.googleapis.com/ml-sysroot-testing/ubuntu18_x86_64_sysroot_gcc8_patched-0.1.0.tar.xz"),
            build_file = Label("//cc/config:sysroot_ubuntu18_x86_64.BUILD"),
            strip_prefix = "ubuntu18_x86_64_sysroot_gcc8_patched-0.1.0",
        )

        # C++20, manylinux_2_31, gcc-10

    #        mirrored_http_archive(
    #            name = "sysroot_linux_x86_64",
    #            sha256 = "39f40d44b24802f6a383ed6c98c2b0b19541b82572f00796ff8d0c01e2bc91b2",
    #            mirrored_tar_sha256 = "a5ff7d9496a48a454ec910499f2bd4d06407f5fc6153cce75fa505cac0ac5726",
    #            urls = tf_mirror_urls("https://storage.googleapis.com/ml-sysroot-testing/sysroot_x86_64_ubuntu20_gcc10.tar.xz"),
    #            build_file = Label("//cc/config:sysroot_ubuntu20_x86_64_gcc10.BUILD"),
    #            strip_prefix = "sysroot_x86_64_ubuntu20_gcc10",
    #        )

    if "sysroot_linux_aarch64" not in native.existing_rules():
        # C++17, manylinux_2_27, gcc-8
        mirrored_http_archive(
            name = "sysroot_linux_aarch64",
            sha256 = "31a285faccb6996c16acde8ef6841841d591f73196dc5b7bdd9cf55b7f0c35a1",
            urls = tf_mirror_urls("https://storage.googleapis.com/ml-sysroot-testing/sysroot_aarch64_ubuntu18_gcc8.4-0.1.0.tar.xz"),
            build_file = Label("//cc/config:sysroot_ubuntu18_aarch64.BUILD"),
            strip_prefix = "sysroot_aarch64_ubuntu18_gcc8.4-0.1.0",
        )

        # C++20, manylinux_2_31, gcc-10

    #        mirrored_http_archive(
    #            name = "sysroot_linux_aarch64",
    #            sha256 = "359a1bdf9e2747c32363abb24c5cecad41cebcbf1257464aeb44b9cba87dc8f0",
    #            mirrored_tar_sha256 = "f52b38be5919a39fac8ec30e52eacced45caffdb00b2c1780904e57009e56096",
    #            urls = tf_mirror_urls("https://storage.googleapis.com/ml-sysroot-testing/sysroot_aarch64_ubuntu20_gcc10.tar.xz"),
    #            build_file = Label("//cc/config:sysroot_ubuntu20_aarch64_gcc10.BUILD"),
    #            strip_prefix = "sysroot_aarch64_ubuntu20_gcc10",
    #        )

    if "sysroot_darwin_aarch64" not in native.existing_rules():
        new_local_repository(
            name = "sysroot_darwin_aarch64",
            build_file = "//cc/config:sysroot_darwin_aarch64.BUILD",
            path = "cc/sysroots/darwin_aarch64/MacOSX.sdk",
        )

    if "llvm_linux_x86_64" not in native.existing_rules():
        # LLVM 18
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

        # LLVM 19

    #        llvm_http_archive(
    #            name = "llvm_linux_x86_64",
    #            urls = tf_mirror_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-19.1.7/LLVM-19.1.7-Linux-X64.tar.xz"),
    #            sha256 = "4a5ec53951a584ed36f80240f6fbf8fdd46b4cf6c7ee87cc2d5018dc37caf679",
    #            build_file = Label("//cc/config:llvm19_linux_x86_64.BUILD"),
    #            strip_prefix = "LLVM-19.1.7-Linux-X64",
    #        )

    if "llvm_linux_aarch64" not in native.existing_rules():
        llvm_http_archive(
            name = "llvm_linux_aarch64",
            urls = tf_mirror_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-18.1.8/clang+llvm-18.1.8-aarch64-linux-gnu.tar.xz"),
            sha256 = "dcaa1bebbfbb86953fdfbdc7f938800229f75ad26c5c9375ef242edad737d999",
            mirrored_tar_sha256 = "26a52cc6c658736f822546f220216178ac50d75ac1809bf8608395c8edd7c2c1",
            build_file = Label("//cc/config:llvm18_linux_aarch64.BUILD"),
            strip_prefix = "clang+llvm-18.1.8-aarch64-linux-gnu",
        )

    if "llvm_darwin_aarch64" not in native.existing_rules():
        llvm_http_archive(
            name = "llvm_darwin_aarch64",
            urls = tf_mirror_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-18.1.8/clang+llvm-18.1.8-arm64-apple-macos11.tar.xz"),
            sha256 = "4573b7f25f46d2a9c8882993f091c52f416c83271db6f5b213c93f0bd0346a10",
            mirrored_tar_sha256 = "abf9636295730364bfe4cfa6b491dc8476587bd6d7271e3011dafdb5e382bcdf",
            build_file = Label("//cc/config:llvm18_darwin_aarch64.BUILD"),
            strip_prefix = "clang+llvm-18.1.8-arm64-apple-macos11",
        )
