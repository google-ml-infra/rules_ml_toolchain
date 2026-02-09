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

"""Module extension for cuda redist repositories."""

load(
    "@cuda_redist_json//:distributions.bzl",
    "CUDA_REDISTRIBUTIONS",
    "CUDNN_REDISTRIBUTIONS",
)
load(
    "//gpu:nvidia_common_rules.bzl",
    "unflatten_dict_from_string_dict",
)
load(
    "//gpu/cuda:cuda_redist_init_repositories.bzl",
    "cuda_redist_init_repositories",
    "cudnn_redist_init_repository",
)
load(
    "//gpu/cuda:cuda_redist_versions.bzl",
    "CUDA_REDIST_PATH_PREFIX",
    "CUDNN_REDIST_PATH_PREFIX",
    "MIRRORED_TAR_CUDA_REDIST_PATH_PREFIX",
    "MIRRORED_TAR_CUDNN_REDIST_PATH_PREFIX",
    "REDIST_VERSIONS_TO_BUILD_TEMPLATES",
)

_configure_tag = tag_class(
    attrs = {
        "cuda_redistributions": attr.string_dict(),
        "cuda_redist_path_prefix": attr.string(
            default = CUDA_REDIST_PATH_PREFIX,
        ),
        "mirrored_tar_cuda_redist_path_prefix": attr.string(
            default = MIRRORED_TAR_CUDA_REDIST_PATH_PREFIX,
        ),
        "redist_versions_to_build_templates": attr.string_dict(),
        "cudnn_redistributions": attr.string_dict(),
        "cudnn_redist_path_prefix": attr.string(
            default = CUDNN_REDIST_PATH_PREFIX,
        ),
        "mirrored_tar_cudnn_redist_path_prefix": attr.string(
            default = MIRRORED_TAR_CUDNN_REDIST_PATH_PREFIX,
        ),
    },
)

def _cuda_redist_init_ext_impl(mctx):
    cuda_kwargs = {}
    cuda_kwargs["cuda_redistributions"] = CUDA_REDISTRIBUTIONS
    cuda_kwargs["redist_versions_to_build_templates"] = REDIST_VERSIONS_TO_BUILD_TEMPLATES
    cudnn_kwargs = {}
    cudnn_kwargs["cudnn_redistributions"] = CUDNN_REDISTRIBUTIONS
    cudnn_kwargs["redist_versions_to_build_templates"] = REDIST_VERSIONS_TO_BUILD_TEMPLATES

    for mod in mctx.modules:
        for tag in mod.tags.configure:
            if tag.cuda_redistributions:
                cuda_kwargs["cuda_redistributions"] = CUDA_REDISTRIBUTIONS | unflatten_dict_from_string_dict(
                    tag.cuda_redistributions,
                )
            if tag.cudnn_redistributions:
                cudnn_kwargs["cudnn_redistributions"] = CUDNN_REDISTRIBUTIONS | unflatten_dict_from_string_dict(
                    tag.cudnn_redistributions,
                )
            if tag.cuda_redist_path_prefix:
                cuda_kwargs["cuda_redist_path_prefix"] = tag.cuda_redist_path_prefix
            if tag.cudnn_redist_path_prefix:
                cudnn_kwargs["cudnn_redist_path_prefix"] = tag.cudnn_redist_path_prefix
            if tag.mirrored_tar_cuda_redist_path_prefix:
                cuda_kwargs["mirrored_tar_cuda_redist_path_prefix"] = tag.mirrored_tar_cuda_redist_path_prefix
            if tag.mirrored_tar_cudnn_redist_path_prefix:
                cudnn_kwargs["mirrored_tar_cudnn_redist_path_prefix"] = tag.mirrored_tar_cudnn_redist_path_prefix
            if tag.redist_versions_to_build_templates:
                redist_versions_to_build_templates = REDIST_VERSIONS_TO_BUILD_TEMPLATES | unflatten_dict_from_string_dict(
                    tag.redist_versions_to_build_templates,
                )
                cuda_kwargs["redist_versions_to_build_templates"] = redist_versions_to_build_templates
                cudnn_kwargs["redist_versions_to_build_templates"] = redist_versions_to_build_templates

    cuda_redist_init_repositories(**cuda_kwargs)
    cudnn_redist_init_repository(**cudnn_kwargs)

cuda_redist_init_ext = module_extension(
    implementation = _cuda_redist_init_ext_impl,
    tag_classes = {"configure": _configure_tag},
)
