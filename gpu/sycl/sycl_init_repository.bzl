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

"""Hermetic SYCL repositories initialization. Consult the WORKSPACE on how to use it."""

load("//gpu/sycl:dist_repo.bzl", "dist_repo")
load(
    "//gpu/sycl:sycl_redist_versions.bzl",
    "BUILD_TEMPLATES",
    "REDIST_DICT",
)
load(
    "//gpu:nvidia_common_rules.bzl",
    "get_redistribution_urls",
    "get_version_and_template_lists",
)

def sycl_init_repository(
        redist_dict = REDIST_DICT,
        build_templates = BUILD_TEMPLATES):
    # buildifier: disable=function-docstring-args
    """Initializes SYCL repositories.

    Please note that this macro should be called from a different file than
    cuda_json_init_repository(). The reason is that cuda_json_init_repository()
    creates distributions.bzl file with "CUDA_REDISTRIBUTIONS" constant that is
    used in this macro."""

    for dist_name, _ in redist_dict.items()[::-1]:
        build_template = build_templates[dist_name]

        dist_repo(
            name = dist_name,
            distrs = redist_dict[dist_name],
            build_templates = build_template["version_to_template"],
        )
