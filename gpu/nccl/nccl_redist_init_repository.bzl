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
    "@rules_ml_toolchain//third_party/nccl/hermetic:nccl_redist_init_repository.bzl",
    "nccl_redist_init_repository_wrapper",
)
load(
    "//third_party/gpus/cuda/hermetic:cuda_redist_versions.bzl",
    "CUDA_NCCL_WHEELS",
    "REDIST_VERSIONS_TO_BUILD_TEMPLATES",
)

def nccl_redist_init_repository(
        cuda_nccl_wheels = CUDA_NCCL_WHEELS,
        redist_versions_to_build_templates = REDIST_VERSIONS_TO_BUILD_TEMPLATES):
    nccl_redist_init_repository_wrapper(
        cuda_nccl_wheels,
        redist_versions_to_build_templates,
    )
