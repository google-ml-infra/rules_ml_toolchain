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
    "//third_party/nvshmem/hermetic:nvshmem_redist_init_repository.bzl",
    "nvshmem_redist_init_repository_wrapper",
)

load(
    "//third_party/gpus/cuda/hermetic:cuda_redist_versions.bzl",
    "MIRRORED_TAR_NVSHMEM_REDIST_PATH_PREFIX",
    "NVSHMEM_REDIST_PATH_PREFIX",
    "NVSHMEM_REDIST_VERSIONS_TO_BUILD_TEMPLATES",
)

def nvshmem_redist_init_repository(
        nvshmem_redistributions,
        nvshmem_redist_path_prefix = NVSHMEM_REDIST_PATH_PREFIX,
        mirrored_tar_nvshmem_redist_path_prefix = MIRRORED_TAR_NVSHMEM_REDIST_PATH_PREFIX,
        redist_versions_to_build_templates = NVSHMEM_REDIST_VERSIONS_TO_BUILD_TEMPLATES):

        nvshmem_redist_init_repository_wrapper(
            nvshmem_redistributions,
            nvshmem_redist_path_prefix,
            mirrored_tar_nvshmem_redist_path_prefix,
            redist_versions_to_build_templates)
