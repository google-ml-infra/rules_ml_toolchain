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
load("//common:tar_extraction_utils.bzl", "tool_archive")
load("//third_party:repo.bzl", "tf_mirror_urls")
load("//cc/llvms:llvm.bzl", "llvm")
load("//cc/sysroots:sysroot.bzl", "sysroot")

def cc_toolchain_deps():
    tool_archive(
        name = "tar",
        linux_x86_64_sha256 = "d3be6744685d7a90adc16e3d5342ba9b28fc388422629a1bea146b3798229af6",
        linux_x86_64_urls = ["https://storage.googleapis.com/ml-sysroot-testing/tar_x86_64-1.35.tar.xz"],
        linux_x86_64_strip_prefix = "tar_x86_64-1.35",
        linux_aarch64_sha256 = "f75b274fdec81fa3563dff722c7cc93403c8d155abdf637f745b44b2ccaeb5d7",
        linux_aarch64_urls = ["https://storage.googleapis.com/ml-sysroot-testing/tar_aarch64_1.35-0.1.0.tar.xz"],
        linux_aarch64_strip_prefix = "tar_aarch64_1.35-0.1.0",
    )

    tool_archive(
        name = "xz",
        linux_x86_64_sha256 = "59b9f6681b2aa395a07908d6875ce47eae8e2a5af496449b827bd0370947d355",
        linux_x86_64_urls = ["https://storage.googleapis.com/ml-sysroot-testing/xz_x86_64-5.8.1.tar.xz"],
        linux_x86_64_strip_prefix = "xz_x86_64-5.8.1",
        linux_aarch64_sha256 = "0ac42974d1bd31c1e10d9c8cdbf98885bdee563b3db11de9ae1e236da02281f7",
        linux_aarch64_urls = ["https://storage.googleapis.com/ml-sysroot-testing/xz_aarch64_5.8.1-0.1.0.tar.xz"],
        linux_aarch64_strip_prefix = "xz_aarch64_5.8.1-0.1.0",
    )

    ################################################################
    # Linux x86_64 sysroot
    ################################################################
    if "sysroot_linux_x86_64" not in native.existing_rules():
        sysroot(
            name = "sysroot_linux_x86_64",
            default_dist = "linux_glibc_2_27",
            dists = {
                "@sysroot_linux_x86_64_glibc_2_27//:startup_libs": "linux_glibc_2_27",
                "@sysroot_linux_x86_64_glibc_2_31//:startup_libs": "linux_glibc_2_31",
                "@sysroot_linux_x86_64_glibc_2_35//:startup_libs": "linux_glibc_2_35",
            },
            build_file_tpl = Label("//cc/sysroots:sysroot_linux.BUILD.tpl"),
        )

    if "sysroot_linux_x86_64_glibc_2_27" not in native.existing_rules():
        # C++17, manylinux_2_27, gcc-8
        mirrored_http_archive(
            name = "sysroot_linux_x86_64_glibc_2_27",
            sha256 = "7d9300ec03d008e96f0098dfcd4e9974dd64f2d5fccdd0f1a2b2d4af63301a04",
            mirrored_tar_sha256 = "8680378000cf63647db5421377fbdb6a4fe98e0207b87f7cfec51883bde587aa",
            urls = tf_mirror_urls("https://storage.googleapis.com/ml-sysroot-testing/ubuntu18_x86_64_sysroot_gcc8_patched-0.1.0.tar.xz"),
            build_file = Label("//cc/config:sysroot_ubuntu18_x86_64.BUILD"),
            strip_prefix = "ubuntu18_x86_64_sysroot_gcc8_patched-0.1.0",
        )

    if "sysroot_linux_x86_64_glibc_2_31" not in native.existing_rules():
        # C++20, manylinux_2_31, gcc-10
        mirrored_http_archive(
            name = "sysroot_linux_x86_64_glibc_2_31",
            sha256 = "18e7dcfc87e6562c85cad9806db79fd3feb943db3ff98ab8c170e308655dfc99",
            urls = tf_mirror_urls("https://storage.googleapis.com/ml-sysroot-testing/sysroot_x86_64_ubuntu20_gcc10-0.1.0.tar.xz"),
            build_file = Label("//cc/config:sysroot_ubuntu20_x86_64_gcc10.BUILD"),
            strip_prefix = "sysroot_x86_64_ubuntu20_gcc10",
        )

    if "sysroot_linux_x86_64_glibc_2_35" not in native.existing_rules():
        # C++20 / C++23 partial support, manylinux_2_35, gcc-12
        mirrored_http_archive(
            name = "sysroot_linux_x86_64_glibc_2_35",
            sha256 = "a24665b464d8d1e2235690dd77f8a5fd2d7f717afe83208635ae1b25ef5874bf",
            urls = tf_mirror_urls("https://storage.googleapis.com/ml-sysroot-testing/sysroot_x86_64_ubuntu22_gcc12-0.0.1.tar.xz"),
            build_file = Label("//cc/config:sysroot_ubuntu22_x86_64_gcc12.BUILD"),
            strip_prefix = "sysroot_x86_64_ubuntu22_gcc12-0.0.1",
        )

    ################################################################
    # Linux aarch64 sysroot
    ################################################################
    if "sysroot_linux_aarch64" not in native.existing_rules():
        sysroot(
            name = "sysroot_linux_aarch64",
            default_dist = "linux_glibc_2_27",
            dists = {
                "@sysroot_linux_aarch64_glibc_2_27//:startup_libs": "linux_glibc_2_27",
                "@sysroot_linux_aarch64_glibc_2_31//:startup_libs": "linux_glibc_2_31",
            },
            build_file_tpl = Label("//cc/sysroots:sysroot_linux.BUILD.tpl"),
        )

    if "sysroot_linux_aarch64_glibc_2_27" not in native.existing_rules():
        # C++17, manylinux_2_27, gcc-8
        mirrored_http_archive(
            name = "sysroot_linux_aarch64_glibc_2_27",
            sha256 = "31a285faccb6996c16acde8ef6841841d591f73196dc5b7bdd9cf55b7f0c35a1",
            mirrored_tar_sha256 = "23989e1c4184b472ffcacf04cfeb7c9e108cb4126aeadb8a326597795b47f175",
            urls = tf_mirror_urls("https://storage.googleapis.com/ml-sysroot-testing/sysroot_aarch64_ubuntu18_gcc8.4-0.1.0.tar.xz"),
            build_file = Label("//cc/config:sysroot_ubuntu18_aarch64.BUILD"),
            strip_prefix = "sysroot_aarch64_ubuntu18_gcc8.4-0.1.0",
        )

    if "sysroot_linux_aarch64_glibc_2_31" not in native.existing_rules():
        # C++20, manylinux_2_31, gcc-10
        mirrored_http_archive(
            name = "sysroot_linux_aarch64_glibc_2_31",
            sha256 = "3f2b534bf8305f0bc750ef570673fabc04c160e72b5eae5948284edda43d11cc",
            urls = tf_mirror_urls("https://storage.googleapis.com/ml-sysroot-testing/sysroot_aarch64_ubuntu20_gcc10-0.1.0.tar.xz"),
            build_file = Label("//cc/config:sysroot_ubuntu20_aarch64_gcc10.BUILD"),
            strip_prefix = "sysroot_aarch64_ubuntu20_gcc10",
        )

    ################################################################
    # Darwin (macOS) aarch64 sysroot
    ################################################################
    if "sysroot_darwin_aarch64" not in native.existing_rules():
        new_local_repository(
            name = "sysroot_darwin_aarch64",
            build_file = "//cc/config:sysroot_darwin_aarch64.BUILD",
            path = "cc/sysroots/darwin_aarch64/MacOSX.sdk",
        )

    ################################################################
    # Linux x86_64 LLVM
    ################################################################
    if "llvm_linux_x86_64" not in native.existing_rules():
        llvm(
            name = "llvm_linux_x86_64",
            default_version = "18",
            versions = {
                "@llvm18_linux_x86_64//:all": "18",
                "@llvm19_linux_x86_64//:all": "19",
                "@llvm20_linux_x86_64//:all": "20",
                "@llvm21_linux_x86_64//:all": "21",
            },
            build_file_tpl = Label("//cc/llvms:llvm_linux.BUILD.tpl"),
        )

    if "llvm18_linux_x86_64" not in native.existing_rules():
        # LLVM 18 Linux x86_64
        mirrored_http_archive(
            name = "llvm18_linux_x86_64",
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

    if "llvm19_linux_x86_64" not in native.existing_rules():
        # LLVM 19 Linux x86_64
        mirrored_http_archive(
            name = "llvm19_linux_x86_64",
            urls = tf_mirror_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-19.1.7/LLVM-19.1.7-Linux-X64.tar.xz"),
            sha256 = "4a5ec53951a584ed36f80240f6fbf8fdd46b4cf6c7ee87cc2d5018dc37caf679",
            mirrored_tar_sha256 = "ecb0a20f3976ccb6f20fe98baeef45cd80c59d7aec971098094518283f1157ff",
            build_file = Label("//cc/config:llvm19_linux_x86_64.BUILD"),
            strip_prefix = "LLVM-19.1.7-Linux-X64",
        )

    if "llvm20_linux_x86_64" not in native.existing_rules():
        # LLVM 20 Linux x86_64
        mirrored_http_archive(
            name = "llvm20_linux_x86_64",
            urls = tf_mirror_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-20.1.8/LLVM-20.1.8-Linux-X64.tar.xz"),
            sha256 = "1ead36b3dfcb774b57be530df42bec70ab2d239fbce9889447c7a29a4ddc1ae6",
            mirrored_tar_sha256 = "57152ed2a054a06dc3fc7abe35da02696fe80d07884de94621726e1ae8d9a53f",
            build_file = Label("//cc/config:llvm20_linux_x86_64.BUILD"),
            strip_prefix = "LLVM-20.1.8-Linux-X64",
        )

    if "llvm21_linux_x86_64" not in native.existing_rules():
        # LLVM 21 Linux x86_64
        mirrored_http_archive(
            name = "llvm21_linux_x86_64",
            urls = tf_mirror_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-21.1.2/LLVM-21.1.2-Linux-X64.tar.xz"),
            sha256 = "38dc1e278b8d688d9f4f1077da1dcda623d9e0dd89ffcf03bc18d3492bbd9cb6",
            mirrored_tar_sha256 = "563f5d0ed531053cf2d726b09b3e023820ff8d771b9ba0f17a2cb32059d96fe8",
            build_file = Label("//cc/config:llvm21_linux_x86_64.BUILD"),
            strip_prefix = "LLVM-21.1.2-Linux-X64",
        )

    ################################################################
    # Linux aarch64 LLVM
    ################################################################
    if "llvm_linux_aarch64" not in native.existing_rules():
        llvm(
            name = "llvm_linux_aarch64",
            default_version = "18",
            versions = {
                "@llvm18_linux_aarch64//:all": "18",
                "@llvm20_linux_aarch64//:all": "20",
            },
            build_file_tpl = Label("//cc/llvms:llvm_linux.BUILD.tpl"),
        )

    if "llvm18_linux_aarch64" not in native.existing_rules():
        # LLVM 18 Linux aarch64
        mirrored_http_archive(
            name = "llvm18_linux_aarch64",
            urls = tf_mirror_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-18.1.8/clang+llvm-18.1.8-aarch64-linux-gnu.tar.xz"),
            sha256 = "dcaa1bebbfbb86953fdfbdc7f938800229f75ad26c5c9375ef242edad737d999",
            mirrored_tar_sha256 = "26a52cc6c658736f822546f220216178ac50d75ac1809bf8608395c8edd7c2c1",
            build_file = Label("//cc/config:llvm18_linux_aarch64.BUILD"),
            strip_prefix = "clang+llvm-18.1.8-aarch64-linux-gnu",
        )

    if "llvm20_linux_aarch64" not in native.existing_rules():
        # LLVM 20 Linux aarch64
        mirrored_http_archive(
            name = "llvm20_linux_aarch64",
            urls = tf_mirror_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-20.1.8/LLVM-20.1.8-Linux-ARM64.tar.xz"),
            sha256 = "b855cc17d935fdd83da82206b7a7cfc680095efd1e9e8182c4a05e761958bef8",
            mirrored_tar_sha256 = "3c932449de47078a5a5c39499e1d741da6df29e767502803c1c7194022720a07",
            build_file = Label("//cc/config:llvm20_linux_aarch64.BUILD"),
            strip_prefix = "LLVM-20.1.8-Linux-ARM64",
        )

    ################################################################
    # Darwin (macOS) aarch64 LLVM
    ################################################################
    if "llvm_darwin_aarch64" not in native.existing_rules():
        llvm(
            name = "llvm_darwin_aarch64",
            default_version = "18",
            versions = {
                "@llvm18_darwin_aarch64//:all": "18",
                "@llvm20_darwin_aarch64//:all": "20",
            },
            build_file_tpl = Label("//cc/llvms:llvm_darwin.BUILD.tpl"),
        )

    if "llvm18_darwin_aarch64" not in native.existing_rules():
        mirrored_http_archive(
            name = "llvm18_darwin_aarch64",
            urls = tf_mirror_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-18.1.8/clang+llvm-18.1.8-arm64-apple-macos11.tar.xz"),
            sha256 = "4573b7f25f46d2a9c8882993f091c52f416c83271db6f5b213c93f0bd0346a10",
            mirrored_tar_sha256 = "abf9636295730364bfe4cfa6b491dc8476587bd6d7271e3011dafdb5e382bcdf",
            build_file = Label("//cc/config:llvm18_darwin_aarch64.BUILD"),
            strip_prefix = "clang+llvm-18.1.8-arm64-apple-macos11",
        )

    if "llvm20_darwin_aarch64" not in native.existing_rules():
        mirrored_http_archive(
            name = "llvm20_darwin_aarch64",
            urls = tf_mirror_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-20.1.8/LLVM-20.1.8-macOS-ARM64.tar.xz"),
            sha256 = "a9a22f450d35f1f73cd61ab6a17c6f27d8f6051d56197395c1eb397f0c9bbec4",
            mirrored_tar_sha256 = "19f015fd93ef0a9963e4cebe02b051e6d357b4ab86bb060ca8ad5141d7284289",
            build_file = Label("//cc/config:llvm20_darwin_aarch64.BUILD"),
            strip_prefix = "LLVM-20.1.8-macOS-ARM64",
        )
