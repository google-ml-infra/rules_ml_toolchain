# Copyright 2024 The TensorFlow Authors. All rights reserved.
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

"""Hermetic CUDA repositories initialization. Consult the WORKSPACE on how to use it."""

load(
    "//gpu:nvidia_common_rules.bzl",
    "get_local_templates",
    "get_patch_to_versions_dict",
    "get_redistribution_urls",
    "get_version_and_template_lists",
    "redist_init_repository",
)
load(
    "//gpu/cuda:cuda_redist_versions.bzl",
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
        redist_versions_to_build_templates = REDIST_VERSIONS_TO_BUILD_TEMPLATES):
    # buildifier: disable=function-docstring-args
    """Initializes CUDNN repository.

    Please note that this macro should be called from a different file than
    cuda_json_init_repository(). The reason is that cuda_json_init_repository()
    creates distributions.bzl file with "CUDNN_REDISTRIBUTIONS" constant that is
    used in this macro."""
    if "cudnn" in cudnn_redistributions.keys():
        url_dict = get_redistribution_urls(cudnn_redistributions["cudnn"])
    else:
        url_dict = {}
    repo_data = redist_versions_to_build_templates["cudnn"]
    versions, templates = get_version_and_template_lists(
        repo_data["version_to_template"],
    )
    local_templates = get_local_templates(repo_data["local"], templates)
    local_source_dirs = repo_data["local"]["source_dirs"]
    redist_init_repository(
        name = repo_data["repo_name"],
        versions = versions,
        build_templates = templates,
        local_build_templates = local_templates,
        url_dict = url_dict,
        redist_path_prefix = cudnn_redist_path_prefix,
        mirrored_tar_redist_path_prefix = mirrored_tar_cudnn_redist_path_prefix,
        redist_version_env_vars = ["HERMETIC_CUDNN_VERSION", "TF_CUDNN_VERSION"],
        local_path_env_var = "LOCAL_CUDNN_PATH",
        use_tar_file_env_var = "USE_CUDA_TAR_ARCHIVE_FILES",
        target_arch_env_var = "CUDA_REDIST_TARGET_PLATFORM",
        local_source_dirs = local_source_dirs,
    )

def _merge_version_to_patches(base_patches, override_patches):
    merged = {}
    for cuda_ver, val in base_patches.items():
        if type(val) == "dict":
            merged[cuda_ver] = dict(val)
        else:
            merged[cuda_ver] = list(val)
    for cuda_ver, val in override_patches.items():
        if type(val) == "dict" and cuda_ver in merged and type(merged[cuda_ver]) == "dict":
            merged_llvm = dict(merged[cuda_ver])
            for llvm_ver, patches in val.items():
                merged_llvm[llvm_ver] = list(patches)
            merged[cuda_ver] = merged_llvm
        elif type(val) == "dict":
            merged[cuda_ver] = dict(val)
        else:
            merged[cuda_ver] = list(val)
    return merged

def cuda_redist_init_repositories(
        cuda_redistributions,
        cuda_redist_path_prefix = CUDA_REDIST_PATH_PREFIX,
        mirrored_tar_cuda_redist_path_prefix = MIRRORED_TAR_CUDA_REDIST_PATH_PREFIX,
        redist_versions_to_build_templates = REDIST_VERSIONS_TO_BUILD_TEMPLATES,
        cuda_redist_patches = {}):
    # buildifier: disable=function-docstring-args
    """Initializes CUDA repositories.

    Please note that this macro should be called from a different file than
    cuda_json_init_repository(). The reason is that cuda_json_init_repository()
    creates distributions.bzl file with "CUDA_REDISTRIBUTIONS" constant that is
    used in this macro."""
    for redist_name, _ in redist_versions_to_build_templates.items():
        if redist_name in ["cudnn", "cuda_nccl"]:
            continue
        if redist_name in cuda_redistributions.keys():
            url_dict = get_redistribution_urls(cuda_redistributions[redist_name])
        else:
            url_dict = {}
        repo_data = redist_versions_to_build_templates[redist_name]
        versions, templates = get_version_and_template_lists(
            repo_data["version_to_template"],
        )
        local_templates = get_local_templates(repo_data["local"], templates)
        local_source_dirs = repo_data["local"]["source_dirs"]
        local_path_env_var = repo_data["local"].get("local_path_env_var") or "LOCAL_CUDA_PATH"
        version_to_patches = _merge_version_to_patches(
            repo_data.get("version_to_patches", {}),
            cuda_redist_patches.get(redist_name, cuda_redist_patches.get(repo_data["repo_name"], {})),
        )
        redist_init_repository(
            name = repo_data["repo_name"],
            versions = versions,
            build_templates = templates,
            local_build_templates = local_templates,
            url_dict = url_dict,
            redist_path_prefix = cuda_redist_path_prefix,
            mirrored_tar_redist_path_prefix = mirrored_tar_cuda_redist_path_prefix,
            redist_version_env_vars = ["HERMETIC_CUDA_VERSION", "TF_CUDA_VERSION"],
            local_path_env_var = local_path_env_var,
            use_tar_file_env_var = "USE_CUDA_TAR_ARCHIVE_FILES",
            target_arch_env_var = "CUDA_REDIST_TARGET_PLATFORM",
            local_source_dirs = local_source_dirs,
            patches = get_patch_to_versions_dict(version_to_patches),
            repository_symlinks = {
                Label("@cuda_cudart//:include/cuda.h"): "include/cuda.h",
                Label("@cuda_nvdisasm//:bin/nvdisasm"): "bin/nvdisasm",
                Label("@cuda_nvvm//:nvvm/bin/cicc"): "nvvm/bin/cicc",
                Label("@cuda_nvvm//:nvvm/libdevice/libdevice.10.bc"): "nvvm/libdevice/libdevice.10.bc",
            } if repo_data["repo_name"] == "cuda_nvcc" else {},
        )
