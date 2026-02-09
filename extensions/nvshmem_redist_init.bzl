# Copyright 2026 Google LLC
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

"""Module extension for nvshmem redist repositories."""

load(
    "@nvshmem_redist_json//:distributions.bzl",
    "NVSHMEM_REDISTRIBUTIONS",
)
load(
    "//gpu:nvidia_common_rules.bzl",
    "unflatten_dict_from_string_dict",
)
load(
    "//gpu/cuda:cuda_redist_versions.bzl",
    "MIRRORED_TAR_NVSHMEM_REDIST_PATH_PREFIX",
    "NVSHMEM_REDIST_PATH_PREFIX",
    "NVSHMEM_REDIST_VERSIONS_TO_BUILD_TEMPLATES",
)
load(
    "//gpu/nvshmem:nvshmem_redist_init_repository.bzl",
    "nvshmem_redist_init_repository",
)

_configure_tag = tag_class(
    attrs = {
        "nvshmem_redistributions": attr.string_dict(),
        "nvshmem_redist_path_prefix": attr.string(
            default = NVSHMEM_REDIST_PATH_PREFIX,
        ),
        "mirrored_tar_nvshmem_redist_path_prefix": attr.string(
            default = MIRRORED_TAR_NVSHMEM_REDIST_PATH_PREFIX,
        ),
        "redist_versions_to_build_templates": attr.string_dict(),
    },
)

def _nvshmem_redist_init_ext_impl(mctx):
    kwargs = {}
    kwargs["nvshmem_redistributions"] = NVSHMEM_REDISTRIBUTIONS
    kwargs["redist_versions_to_build_templates"] = NVSHMEM_REDIST_VERSIONS_TO_BUILD_TEMPLATES

    for mod in mctx.modules:
        for tag in mod.tags.configure:
            if tag.nvshmem_redistributions:
                kwargs["nvshmem_redistributions"] = NVSHMEM_REDISTRIBUTIONS | unflatten_dict_from_string_dict(
                    tag.nvshmem_redistributions,
                )
            if tag.nvshmem_redist_path_prefix:
                kwargs["nvshmem_redist_path_prefix"] = tag.nvshmem_redist_path_prefix
            if tag.mirrored_tar_nvshmem_redist_path_prefix:
                kwargs["mirrored_tar_nvshmem_redist_path_prefix"] = tag.mirrored_tar_nvshmem_redist_path_prefix
            if tag.redist_versions_to_build_templates:
                redist_versions_to_build_templates = NVSHMEM_REDIST_VERSIONS_TO_BUILD_TEMPLATES | unflatten_dict_from_string_dict(
                    tag.redist_versions_to_build_templates,
                )
                kwargs["redist_versions_to_build_templates"] = redist_versions_to_build_templates

    nvshmem_redist_init_repository(**kwargs)

nvshmem_redist_init_ext = module_extension(
    implementation = _nvshmem_redist_init_ext_impl,
    tag_classes = {"configure": _configure_tag},
)
