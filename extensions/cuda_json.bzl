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

"""Module extension for cuda_json_init_repository."""

load(
    "//gpu:nvidia_common_rules.bzl",
    "unflatten_dict_from_string_dict",
)
load("//gpu/cuda:cuda_json_init_repository.bzl", "cuda_json_init_repository")
load(
    "//gpu/cuda:cuda_redist_versions.bzl",
    "CUDA_REDIST_JSON_DICT",
    "CUDNN_REDIST_JSON_DICT",
    "MIRRORED_TARS_CUDA_REDIST_JSON_DICT",
    "MIRRORED_TARS_CUDNN_REDIST_JSON_DICT",
)

def _cuda_json_ext_impl(mctx):
    kwargs = {}
    kwargs["cuda_json_dict"] = CUDA_REDIST_JSON_DICT
    kwargs["cudnn_json_dict"] = CUDNN_REDIST_JSON_DICT
    kwargs["mirrored_tars_cuda_json_dict"] = MIRRORED_TARS_CUDA_REDIST_JSON_DICT
    kwargs["mirrored_tars_cudnn_json_dict"] = MIRRORED_TARS_CUDNN_REDIST_JSON_DICT

    for mod in mctx.modules:
        for tag in mod.tags.configure:
            if tag.cuda_json_dict:
                kwargs["cuda_json_dict"] = CUDA_REDIST_JSON_DICT | unflatten_dict_from_string_dict(
                    tag.cuda_json_dict,
                )
            if tag.cudnn_json_dict:
                kwargs["cudnn_json_dict"] = CUDNN_REDIST_JSON_DICT | unflatten_dict_from_string_dict(
                    tag.cudnn_json_dict,
                )
            if tag.mirrored_tars_cuda_json_dict:
                kwargs["mirrored_tars_cuda_json_dict"] = MIRRORED_TARS_CUDA_REDIST_JSON_DICT | unflatten_dict_from_string_dict(
                    tag.mirrored_tars_cuda_json_dict,
                )
            if tag.mirrored_tars_cudnn_json_dict:
                kwargs["mirrored_tars_cudnn_json_dict"] = MIRRORED_TARS_CUDNN_REDIST_JSON_DICT | unflatten_dict_from_string_dict(
                    tag.mirrored_tars_cudnn_json_dict,
                )
    cuda_json_init_repository(**kwargs)

_configure_tag = tag_class(
    attrs = {
        "cuda_json_dict": attr.string_dict(),
        "cudnn_json_dict": attr.string_dict(),
        "mirrored_tars_cuda_json_dict": attr.string_dict(),
        "mirrored_tars_cudnn_json_dict": attr.string_dict(),
    },
)

cuda_json_ext = module_extension(
    implementation = _cuda_json_ext_impl,
    tag_classes = {"configure": _configure_tag},
)
