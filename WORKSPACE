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

workspace(
    name = "rules_ml_toolchain",
)

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "bazel_features",
    sha256 = "ba1282c1aa1d1fffdcf994ab32131d7c7551a9bc960fbf05f42d55a1b930cbfb",
    strip_prefix = "bazel_features-1.15.0",
    url = "https://github.com/bazel-contrib/bazel_features/releases/download/v1.15.0/bazel_features-v1.15.0.tar.gz",
)

load("@bazel_features//:deps.bzl", "bazel_features_deps")
bazel_features_deps()

http_archive(
    name = "rules_java",
    sha256 = "a9690bc00c538246880d5c83c233e4deb83fe885f54c21bb445eb8116a180b83",
    urls = ["https://github.com/bazelbuild/rules_java/releases/download/7.12.2/rules_java-7.12.2.tar.gz"],
)

### bazel_skylib
http_archive(
    name = "bazel_skylib",
    sha256 = "fa01292859726603e3cd3a0f3f29625e68f4d2b165647c72908045027473e933",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.8.0/bazel-skylib-1.8.0.tar.gz",
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.8.0/bazel-skylib-1.8.0.tar.gz",
    ],
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

http_archive(
    name = "platforms",
    sha256 = "29742e87275809b5e598dc2f04d86960cc7a55b3067d97221c9abbc9926bff0f",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/platforms/releases/download/0.0.11/platforms-0.0.11.tar.gz",
        "https://github.com/bazelbuild/platforms/releases/download/0.0.11/platforms-0.0.11.tar.gz",
    ],
)

# Initialize hermetic Python
load("//py/deps:rules_python_deps.bzl", "rules_python_deps")
rules_python_deps()

load("//py:python_init_repositories.bzl", "python_init_repositories")
python_init_repositories(
    default_python_version = "system",
    requirements = {
        "3.11": "//build:requirements_lock_3_11.txt",
        "3.12": "//build:requirements_lock_3_12.txt",
        "3.13": "//build:requirements_lock_3_13.txt",
        "3.14": "//build:requirements_lock_3_14.txt",
        "3.13-ft": "//build:requirements_lock_3_13_ft.txt",
        "3.14-ft": "//build:requirements_lock_3_14_ft.txt",
    },
)

load("//py:python_register_toolchain.bzl", "python_register_toolchain")
python_register_toolchain()

load("//py:python_configure.bzl", "python_configure")
python_configure(name = "local_config_python")

http_archive(
    name = "com_google_absl",
    sha256 = "d1abe9da2003e6cbbd7619b0ced3e52047422f4f4ac6c66a9bef5d2e99fea837",
    strip_prefix = "abseil-cpp-d38452e1ee03523a208362186fd42248ff2609f6",
    urls = ["https://github.com/abseil/abseil-cpp/archive/d38452e1ee03523a208362186fd42248ff2609f6.tar.gz"],
)

http_archive(
    name = "pybind11_bazel",
    strip_prefix = "pybind11_bazel-faf56fb3df11287f26dbc66fdedf60a2fc2c6631",
    urls = ["https://github.com/pybind/pybind11_bazel/archive/faf56fb3df11287f26dbc66fdedf60a2fc2c6631.zip"],
)

http_archive(
    name = "pybind11",
    urls = ["https://github.com/pybind/pybind11/archive/v2.13.6.tar.gz"],
    sha256 = "e08cb87f4773da97fa7b5f035de8763abc656d87d5773e62f6da0587d1f0ec20",
    strip_prefix = "pybind11-2.13.6",
    build_file = "//third_party/py:pybind11.BUILD",
)

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")
protobuf_deps()

# Cross compilation error with older version. Details: https://github.com/bulletphysics/bullet3/issues/4607
http_archive(
    name = "zlib",
    build_file = "@com_google_protobuf//:third_party/zlib.BUILD",
    sha256 = "38ef96b8dfe510d42707d9c781877914792541133e1870841463bfa73f883e32",
    strip_prefix = "zlib-1.3.1",
    urls = [
        "https://github.com/madler/zlib/releases/download/v1.3.1/zlib-1.3.1.tar.xz",
        "https://zlib.net/zlib-1.3.1.tar.xz",
    ],
)

http_archive(
    name = "gtest",
    sha256 = "ffa17fbc5953900994e2deec164bb8949879ea09b411e07f215bfbb1f87f4632",
    strip_prefix = "googletest-1.13.0",
    url = "https://github.com/google/googletest/archive/refs/tags/v1.13.0.zip",
)

##############################################################
# Hermetic toolchain configuration

load("//cc/deps:cc_toolchain_deps.bzl", "cc_toolchain_deps")

cc_toolchain_deps()

register_toolchains("//cc/...")

##############################################################
# CUDA
load(
    "//gpu/cuda:cuda_json_init_repository.bzl",
    "cuda_json_init_repository",
)

cuda_json_init_repository()

load(
    "@cuda_redist_json//:distributions.bzl",
    "CUDA_REDISTRIBUTIONS",
    "CUDNN_REDISTRIBUTIONS",
)
load(
    "//gpu/cuda:cuda_redist_init_repositories.bzl",
    "cuda_redist_init_repositories",
    "cudnn_redist_init_repository",
)

cuda_redist_init_repositories(
    cuda_redistributions = CUDA_REDISTRIBUTIONS,
)

cudnn_redist_init_repository(
    cudnn_redistributions = CUDNN_REDISTRIBUTIONS,
)

load(
    "//gpu/cuda:cuda_configure.bzl",
    "cuda_configure",
)

cuda_configure(name = "local_config_cuda")

##############################################################
# NCCL configuration
load(
    "//gpu/nccl:nccl_redist_init_repository.bzl",
    "nccl_redist_init_repository",
)

nccl_redist_init_repository()

load(
    "//gpu/nccl:nccl_configure.bzl",
    "nccl_configure",
)

nccl_configure(name = "local_config_nccl")

##############################################################
# NVSHMEM configuration

load(
    "//gpu/nvshmem:nvshmem_json_init_repository.bzl",
    "nvshmem_json_init_repository",
)

nvshmem_json_init_repository()

load(
    "@nvshmem_redist_json//:distributions.bzl",
    "NVSHMEM_REDISTRIBUTIONS",
)
load(
    "//gpu/nvshmem:nvshmem_redist_init_repository.bzl",
    "nvshmem_redist_init_repository",
)

nvshmem_redist_init_repository(
    nvshmem_redistributions = NVSHMEM_REDISTRIBUTIONS,
)

################################################################
# SYCL configure
load(
    "//gpu/sycl:sycl_init_repository.bzl",
    "sycl_init_repository",
)

sycl_init_repository()

load("//gpu/sycl:sycl_configure.bzl", "sycl_configure")

sycl_configure(name = "local_config_sycl")
