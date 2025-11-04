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

# oneAPI variables and system paths example

# config = find_sycl_config(repository_ctx)
# sycl_basekit_path = config["sycl_basekit_path"]
# sycl_toolkit_path = config["sycl_toolkit_path"]
# sycl_version_number = config["sycl_version_number"]
# sycl_basekit_version_number = config["sycl_basekit_version_number"]

# mkl_include_dir: /opt/intel/oneapi/mkl/2025.2/include
# mkl_library_dir: /opt/intel/oneapi/mkl/2025.2/lib

# sycl_basekit_path: /opt/intel/oneapi
# sycl_basekit_version_number: 2025.2

# sycl_toolkit_path: /opt/intel/oneapi/compiler/2025.2
# sycl_version_number: 80000

load(
    "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl",
    "cc_toolchain_import",
)

load(
    "@rules_ml_toolchain//gpu/sycl:oneapi_feature.bzl",
    "oneapi_feature",
)

package(
    default_visibility = [
        "//visibility:public",
    ],
)

ONEAPI_VERSION = "2025.1"
CLANG_VERSION = "20"

filegroup(
    name = "all",
    srcs = glob([
            "advisor/2021.15/**",
            "ccl/2021.15/**",
            "common/{oneapi_version}/**".format(oneapi_version = ONEAPI_VERSION),
            "compiler/{oneapi_version}/**".format(oneapi_version = ONEAPI_VERSION),
            "dal/2025.5/env/**",
            "dal/2025.5/etc/**",
            "dal/2025.5/include/**",
            "dal/2025.5/lib/libone*",
            "dal/2025.5/lib/pkgconfig/**",
            "dal/2025.5/share/**",
            "dev-utilities/**",
            "dnnl/**",
            "dpcpp-ct/**",
            "dpl/**",
            "installer/**",
            "ipp/2022.1/env/**",
            "ipp/2022.1/etc/**",
            "ipp/2022.1/include/**",
            "ipp/2022.1/lib/lib*",
            "ipp/2022.1/lib/nonpic/**",
            "ipp/2022.1/lib/pkgconfig/**",
            "ipp/2022.1/opt/**",
            "ipp/2022.1/share/**",
            "ippcp/{oneapi_version}/env/**".format(oneapi_version = ONEAPI_VERSION),
            "ippcp/{oneapi_version}/etc/**".format(oneapi_version = ONEAPI_VERSION),
            "ippcp/{oneapi_version}/include/**".format(oneapi_version = ONEAPI_VERSION),
            "ippcp/{oneapi_version}/lib/lib*".format(oneapi_version = ONEAPI_VERSION),
            "ippcp/{oneapi_version}/lib/nonpic/**".format(oneapi_version = ONEAPI_VERSION),
            "ippcp/{oneapi_version}/lib/pkgconfig/**".format(oneapi_version = ONEAPI_VERSION),
            "ippcp/{oneapi_version}/opt/**".format(oneapi_version = ONEAPI_VERSION),
            "ippcp/{oneapi_version}/share/**".format(oneapi_version = ONEAPI_VERSION),
            "mkl/{oneapi_version}/bin/**".format(oneapi_version = ONEAPI_VERSION),
            "mkl/{oneapi_version}/env/**".format(oneapi_version = ONEAPI_VERSION),
            "mkl/{oneapi_version}/etc/**".format(oneapi_version = ONEAPI_VERSION),
            "mkl/{oneapi_version}/include/**".format(oneapi_version = ONEAPI_VERSION),
            "mkl/{oneapi_version}/lib/lib*".format(oneapi_version = ONEAPI_VERSION),
            "mkl/{oneapi_version}/lib/pkgconfig/**".format(oneapi_version = ONEAPI_VERSION),
            "mkl/{oneapi_version}/share/**".format(oneapi_version = ONEAPI_VERSION),
            "mpi/2021.15/bin/**",
            "mpi/2021.15/env/**",
            "mpi/2021.15/etc/**",
            "mpi/2021.15/include/**",
            "mpi/2021.15/lib/lib*",
            "mpi/2021.15/lib/mpi/**",
            "mpi/2021.15/lib/pkgconfig/**",
            "mpi/2021.15/opt/**",
            "mpi/2021.15/share/**",
            "pti/0.12/**",
            "tbb/2022.1/env/**",
            "tbb/2022.1/etc/**",
            "tbb/2022.1/include/**",
            "tbb/2022.1/lib/lib*",
            "tbb/2022.1/lib/pkgconfig/**",
            "tbb/2022.1/share/**",
            "tcm/1.3/**",
            "umf/0.10/**",
            "vtune/2025.3/**",
        ]
    ),
)

oneapi_feature(
    name = "binaries",
    enabled = True,
    lib_paths = [
        ":compiler/{oneapi_version}/lib".format(oneapi_version = ONEAPI_VERSION),
        ":compiler/{oneapi_version}/compiler/lib/intel64_lin".format(oneapi_version = ONEAPI_VERSION),
    ],
    icpx_path = ":compiler/{oneapi_version}/bin/icpx".format(oneapi_version = ONEAPI_VERSION),
    clang_path = ":compiler/{oneapi_version}/bin/compiler/clang".format(oneapi_version = ONEAPI_VERSION),
    version = "2025.1",
    verbose = True
)

filegroup(
    name = "clang",
    srcs = [
        "compiler/{oneapi_version}/bin/compiler/clang".format(oneapi_version = ONEAPI_VERSION),
    ],
)

filegroup(
    name = "clang++",
    srcs = [
        "compiler/{oneapi_version}/bin/compiler/clang++".format(oneapi_version = ONEAPI_VERSION),
    ],
)

filegroup(
    name = "clang-offload-bundler",
    srcs = [
        "compiler/{oneapi_version}/bin/compiler/clang-offload-bundler".format(oneapi_version = ONEAPI_VERSION),
    ],
)

filegroup(
    name = "clang-offload-wrapper",
    srcs = [
        "compiler/{oneapi_version}/bin/compiler/clang-offload-wrapper".format(oneapi_version = ONEAPI_VERSION),
    ],
)

filegroup(
    name = "file-table-tform",
    srcs = [
        "compiler/{oneapi_version}/bin/compiler/file-table-tform".format(oneapi_version = ONEAPI_VERSION),
    ],
)

filegroup(
    name = "spirv-to-ir-wrapper",
    srcs = [
        "compiler/{oneapi_version}/bin/compiler/spirv-to-ir-wrapper".format(oneapi_version = ONEAPI_VERSION),
    ],
)

filegroup(
    name = "sycl-post-link",
    srcs = [
        "compiler/{oneapi_version}/bin/compiler/sycl-post-link".format(oneapi_version = ONEAPI_VERSION),
    ],
)

filegroup(
    name = "llvm-foreach",
    srcs = [
        "compiler/{oneapi_version}/bin/compiler/llvm-foreach".format(oneapi_version = ONEAPI_VERSION),
    ],
)
filegroup(
    name = "llvm-objcopy",
    srcs = [
        "compiler/{oneapi_version}/bin/compiler/llvm-objcopy".format(oneapi_version = ONEAPI_VERSION),
    ],
)

filegroup(
    name = "llvm-link",
    srcs = [
        "compiler/{oneapi_version}/bin/compiler/llvm-link".format(oneapi_version = ONEAPI_VERSION),
    ],
)

filegroup(
    name = "llvm-spirv",
    srcs = [
        "compiler/{oneapi_version}/bin/compiler/llvm-spirv".format(oneapi_version = ONEAPI_VERSION),
    ],
)

filegroup(
    name = "ld",
    srcs = [
        "compiler/{oneapi_version}/bin/compiler/ld.lld".format(oneapi_version = ONEAPI_VERSION),
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "ar",
    srcs = [
        "compiler/{oneapi_version}/bin/compiler/llvm-ar".format(oneapi_version = ONEAPI_VERSION),
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "icpx",
    srcs = [
        "compiler/{oneapi_version}/bin/icpx".format(oneapi_version = ONEAPI_VERSION),
    ],
)

filegroup(
    name = "asan_ignorelist",
    srcs = [
        "compiler/{oneapi_version}/lib/clang/{clang_version}/share/asan_ignorelist.txt"
            .format(oneapi_version = ONEAPI_VERSION, clang_version = CLANG_VERSION),
    ],
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "includes",
    hdrs = glob([
        "compiler/{oneapi_version}/lib/clang/{clang_version}/include/**"
            .format(oneapi_version = ONEAPI_VERSION, clang_version = CLANG_VERSION),
    ]),
    includes = [
        "compiler/{oneapi_version}/lib/clang/{clang_version}"
            .format(oneapi_version = ONEAPI_VERSION, clang_version = CLANG_VERSION),
        "compiler/{oneapi_version}/lib/clang/{clang_version}/include"
            .format(oneapi_version = ONEAPI_VERSION, clang_version = CLANG_VERSION),
    ],
    target_compatible_with = select({
        "@platforms//os:linux": [],
        "@platforms//os:macos": [],
    }),
    visibility = ["//visibility:public"],
)

# This library is needed for LiteRT because it uses a compiler-specific
# built-in functions, and these functions are not provided by GCC 8.4.
cc_toolchain_import(
    name = "libclang_rt",
    static_library = "compiler/{oneapi_version}/lib/clang/{clang_version}/lib/x86_64-unknown-linux-gnu/libclang_rt.builtins.a"
        .format(oneapi_version = ONEAPI_VERSION, clang_version = CLANG_VERSION),
    target_compatible_with = select({
        "@platforms//os:linux": [],
        "@platforms//os:macos": [],
    }),
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "includes_sycl",
    hdrs = glob([
        "compiler/{oneapi_version}/include/**".format(oneapi_version = ONEAPI_VERSION),
    ]),
    includes = [
        "compiler/{oneapi_version}/include".format(oneapi_version = ONEAPI_VERSION),
    ],
)

cc_toolchain_import(
    name = "includes_mkl",
    hdrs = glob([
        "mkl/{oneapi_version}/include/**".format(oneapi_version = ONEAPI_VERSION),
    ]),
    includes = [
        "mkl/{oneapi_version}/include".format(oneapi_version = ONEAPI_VERSION),
    ],
)

cc_toolchain_import(
    name = "core",
    additional_libs = glob([
        "compiler/{oneapi_version}/lib/*".format(oneapi_version = ONEAPI_VERSION),
    ]),
    visibility = ["//visibility:public"],
)

cc_toolchain_import(
    name = "mkl",
    additional_libs = glob([
        "mkl/{oneapi_version}/lib/libmkl_intel_ilp64.s*".format(oneapi_version = ONEAPI_VERSION),
        "mkl/{oneapi_version}/lib/libmkl_sequential.s*".format(oneapi_version = ONEAPI_VERSION),
        "mkl/{oneapi_version}/lib/libmkl_core.s*".format(oneapi_version = ONEAPI_VERSION),
        "mkl/{oneapi_version}/lib/libmkl_sycl_*".format(oneapi_version = ONEAPI_VERSION),
    ]),
    visibility = ["//visibility:public"],
)

cc_library(
    name = "headers",
    hdrs = glob([
        "mkl/{oneapi_version}/include/**".format(oneapi_version = ONEAPI_VERSION),
        "compiler/{oneapi_version}/include/**".format(oneapi_version = ONEAPI_VERSION),
    ]),
    includes = [
        "mkl/{oneapi_version}/include".format(oneapi_version = ONEAPI_VERSION),
        "compiler/{oneapi_version}/include".format(oneapi_version = ONEAPI_VERSION),
    ],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "libs",
    srcs = glob([
        "mkl/{oneapi_version}/lib/libmkl_intel_ilp64.so".format(oneapi_version = ONEAPI_VERSION),
        "mkl/{oneapi_version}/lib/libmkl_sequential.so".format(oneapi_version = ONEAPI_VERSION),
        "mkl/{oneapi_version}/lib/libmkl_core.so".format(oneapi_version = ONEAPI_VERSION),
        "mkl/{oneapi_version}/lib/libmkl_sycl_stats.so".format(oneapi_version = ONEAPI_VERSION),
        "mkl/{oneapi_version}/lib/libmkl_sycl_data_fitting.so".format(oneapi_version = ONEAPI_VERSION),
        "mkl/{oneapi_version}/lib/libmkl_sycl_vm.so".format(oneapi_version = ONEAPI_VERSION),
        "mkl/{oneapi_version}/lib/libmkl_sycl_lapack.so".format(oneapi_version = ONEAPI_VERSION),
        "mkl/{oneapi_version}/lib/libmkl_sycl_dft.so".format(oneapi_version = ONEAPI_VERSION),
        "mkl/{oneapi_version}/lib/libmkl_sycl_sparse.so".format(oneapi_version = ONEAPI_VERSION),
        "mkl/{oneapi_version}/lib/libmkl_sycl_rng.so".format(oneapi_version = ONEAPI_VERSION),
        "mkl/{oneapi_version}/lib/libmkl_sycl_blas.so".format(oneapi_version = ONEAPI_VERSION),
    ]),
    data = glob([
        "mkl/{oneapi_version}/lib/libmkl_intel_ilp64.so".format(oneapi_version = ONEAPI_VERSION),
        "mkl/{oneapi_version}/lib/libmkl_sequential.so".format(oneapi_version = ONEAPI_VERSION),
        "mkl/{oneapi_version}/lib/libmkl_core.so".format(oneapi_version = ONEAPI_VERSION),
        "mkl/{oneapi_version}/lib/libmkl_sycl_stats.so".format(oneapi_version = ONEAPI_VERSION),
        "mkl/{oneapi_version}/lib/libmkl_sycl_data_fitting.so".format(oneapi_version = ONEAPI_VERSION),
        "mkl/{oneapi_version}/lib/libmkl_sycl_vm.so".format(oneapi_version = ONEAPI_VERSION),
        "mkl/{oneapi_version}/lib/libmkl_sycl_lapack.so".format(oneapi_version = ONEAPI_VERSION),
        "mkl/{oneapi_version}/lib/libmkl_sycl_dft.so".format(oneapi_version = ONEAPI_VERSION),
        "mkl/{oneapi_version}/lib/libmkl_sycl_sparse.so".format(oneapi_version = ONEAPI_VERSION),
        "mkl/{oneapi_version}/lib/libmkl_sycl_rng.so".format(oneapi_version = ONEAPI_VERSION),
        "mkl/{oneapi_version}/lib/libmkl_sycl_blas.so".format(oneapi_version = ONEAPI_VERSION),
    ]),
    linkopts = ["-Wl,-Bstatic,-lsvml,-lirng,-limf,-lirc,-lirc_s,-Bdynamic"],
    linkstatic = 1,
    visibility = ["//visibility:public"],
)
