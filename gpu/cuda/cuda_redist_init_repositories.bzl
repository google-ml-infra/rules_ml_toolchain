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

""" TODO(yuriit): Replace this stub file with a file that has real logic """

load(
    "//third_party/gpus/cuda/hermetic:cuda_redist_init_repositories.bzl",
    "cuda_redist_init_repositories_wrapper",
    "cudnn_redist_init_repository_wrapper",
)

load(
    "//third_party/gpus/cuda/hermetic:cuda_redist_versions.bzl",
    "CUDA_REDIST_PATH_PREFIX",
    "CUDNN_REDIST_PATH_PREFIX",
    "MIRRORED_TAR_CUDA_REDIST_PATH_PREFIX",
    "MIRRORED_TAR_CUDNN_REDIST_PATH_PREFIX",
    "REDIST_VERSIONS_TO_BUILD_TEMPLATES",
)

def cudnn_redist_init_repository(
        cudnn_redistributions,
        cudnn_redist_path_prefix = CUDNN_REDIST_PATH_PREFIX,
        mirrored_tar_cudnn_redist_path_prefix = MIRRORED_TAR_CUDNN_REDIST_PATH_PREFIX,
        redist_versions_to_build_templates = REDIST_VERSIONS_TO_BUILD_TEMPLATES,
        custom_build_templates = {}):
    cudnn_redist_init_repository_wrapper(
        cudnn_redistributions,
        cudnn_redist_path_prefix,
        mirrored_tar_cudnn_redist_path_prefix,
        redist_versions_to_build_templates,
        custom_build_templates)

def cuda_redist_init_repositories(
        cuda_redistributions,
        cuda_redist_path_prefix = CUDA_REDIST_PATH_PREFIX,
        mirrored_tar_cuda_redist_path_prefix = MIRRORED_TAR_CUDA_REDIST_PATH_PREFIX,
        redist_versions_to_build_templates = REDIST_VERSIONS_TO_BUILD_TEMPLATES,
        custom_build_templates = {}):
    cuda_redist_init_repositories_wrapper(cuda_redistributions,
        cuda_redist_path_prefix,
        mirrored_tar_cuda_redist_path_prefix,
        redist_versions_to_build_templates,
        custom_build_templates)
