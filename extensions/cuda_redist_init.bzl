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
load(
    "//gpu/cuda:cuda_redist_versions.bzl",
    "REDIST_VERSIONS_TO_BUILD_TEMPLATES",
)

def _cuda_redist_init_ext_impl(mctx):
    cuda_redist_patches = {}

    # Process modules from dependencies to root module so that root module tags
    # take precedence for the same (redist_name, cuda_version, llvm_version).
    for mod in reversed(mctx.modules):
        mod_patches = {}
        for tag in mod.tags.patch:
            redist_patches = mod_patches.setdefault(tag.redist_name, {})
            cuda_ver_patches = redist_patches.setdefault(tag.cuda_version, {})
            llvm_ver_patches = cuda_ver_patches.setdefault(tag.llvm_version, [])
            for patch in tag.patches:
                if patch not in llvm_ver_patches:
                    llvm_ver_patches.append(patch)
        for redist_name, redist_dict in mod_patches.items():
            target_redist = cuda_redist_patches.setdefault(redist_name, {})
            for cuda_ver, cuda_dict in redist_dict.items():
                target_cuda = target_redist.setdefault(cuda_ver, {})
                for llvm_ver, patches in cuda_dict.items():
                    target_cuda[llvm_ver] = patches

    cuda_redist_init_repositories(
        cuda_redistributions = CUDA_REDISTRIBUTIONS,
        redist_versions_to_build_templates = REDIST_VERSIONS_TO_BUILD_TEMPLATES,
        cuda_redist_patches = cuda_redist_patches,
    )
    cudnn_redist_init_repository(
        cudnn_redistributions = CUDNN_REDISTRIBUTIONS,
    )

_patch_tag = tag_class(
    attrs = {
        "redist_name": attr.string(
            default = "cuda_nvcc",
            doc = "Name of the CUDA redistribution repository to patch (default: 'cuda_nvcc').",
        ),
        "cuda_version": attr.string(
            default = "any",
            doc = "Full CUDA version to match (e.g., '12.9.1'), or 'any'.",
        ),
        "llvm_version": attr.string(
            default = "any",
            doc = "LLVM version to match (e.g., '22'), or 'any'.",
        ),
        "patches": attr.label_list(
            allow_files = True,
            mandatory = True,
            doc = "List of patch file labels to apply when cuda_version and llvm_version match.",
        ),
    },
    doc = "Configure patches to apply to a hermetic CUDA redistribution repository.",
)

# TODO(ybaturina): add missing features from workspace mode
cuda_redist_init_ext = module_extension(
    implementation = _cuda_redist_init_ext_impl,
    tag_classes = {"patch": _patch_tag},
)
