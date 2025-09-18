# Copyright 2025 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Module extension for cuda redist repositories."""

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

def _cuda_redist_init_ext_impl(mctx):
    cuda_redist_init_repositories(
        cuda_redistributions = CUDA_REDISTRIBUTIONS,
    )
    cudnn_redist_init_repository(
        cudnn_redistributions = CUDNN_REDISTRIBUTIONS,
    )

cuda_redist_init_ext = module_extension(
    implementation = _cuda_redist_init_ext_impl,
)
