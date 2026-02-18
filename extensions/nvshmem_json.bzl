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

"""Module extension for nvshmem_json_init_repository."""

load(
    "//gpu:nvidia_common_rules.bzl",
    "flatten_dict_for_string_dict",
    "unflatten_dict_from_string_dict",
)
load(
    "//gpu/cuda:cuda_redist_versions.bzl",
    "MIRRORED_TARS_NVSHMEM_REDIST_JSON_DICT",
    "NVSHMEM_REDIST_JSON_DICT",
)
load("//gpu/nvshmem:nvshmem_json_init_repository.bzl", "nvshmem_json_init_repository")

def _nvshmem_json_ext_impl(mctx):
    kwargs = {}
    kwargs["nvshmem_json_dict"] = NVSHMEM_REDIST_JSON_DICT
    kwargs["mirrored_tars_nvshmem_json_dict"] = MIRRORED_TARS_NVSHMEM_REDIST_JSON_DICT

    for mod in mctx.modules:
        for tag in mod.tags.configure:
            if tag.nvshmem_json_dict:
                kwargs["nvshmem_json_dict"] = NVSHMEM_REDIST_JSON_DICT | unflatten_dict_from_string_dict(
                    tag.nvshmem_json_dict,
                )
            if tag.mirrored_tars_nvshmem_json_dict:
                kwargs["mirrored_tars_nvshmem_json_dict"] = MIRRORED_TARS_NVSHMEM_REDIST_JSON_DICT | unflatten_dict_from_string_dict(
                    tag.mirrored_tars_nvshmem_json_dict,
                )
    nvshmem_json_init_repository(**kwargs)

_configure_tag = tag_class(
    attrs = {
        "nvshmem_json_dict": attr.string_dict(),
        "mirrored_tars_nvshmem_json_dict": attr.string_dict(),
    },
)

nvshmem_json_ext = module_extension(
    implementation = _nvshmem_json_ext_impl,
    tag_classes = {"configure": _configure_tag},
)
