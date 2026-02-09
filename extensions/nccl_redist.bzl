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

"""Module extension for nccl_redist_init_repository."""

load(
    "//gpu:nvidia_common_rules.bzl",
    "unflatten_dict_from_string_dict",
)
load(
    "//gpu/cuda:cuda_redist_versions.bzl",
    "CUDA_NCCL_WHEELS",
    "REDIST_VERSIONS_TO_BUILD_TEMPLATES",
)
load(
    "//gpu/nccl:nccl_redist_init_repository.bzl",
    "nccl_redist_init_repository",
)

def _nccl_redist_ext_impl(mctx):
    kwargs = {}
    kwargs["cuda_nccl_wheels"] = CUDA_NCCL_WHEELS
    kwargs["redist_versions_to_build_templates"] = REDIST_VERSIONS_TO_BUILD_TEMPLATES

    for mod in mctx.modules:
        for tag in mod.tags.configure:
            if tag.cuda_nccl_wheels:
                kwargs["cuda_nccl_wheels"] = CUDA_NCCL_WHEELS | unflatten_dict_from_string_dict(
                    tag.cuda_nccl_wheels,
                )
            if tag.redist_versions_to_build_templates:
                redist_versions_to_build_templates = REDIST_VERSIONS_TO_BUILD_TEMPLATES | unflatten_dict_from_string_dict(
                    tag.redist_versions_to_build_templates,
                )
                kwargs["redist_versions_to_build_templates"] = redist_versions_to_build_templates

    nccl_redist_init_repository(**kwargs)

_configure_tag = tag_class(
    attrs = {
        "cuda_nccl_wheels": attr.string_dict(),
        "redist_versions_to_build_templates": attr.string_dict(),
    },
)

nccl_redist_ext = module_extension(
    implementation = _nccl_redist_ext_impl,
    tag_classes = {"configure": _configure_tag},
)
