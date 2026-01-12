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

"""Hermetic NCCL repositories initialization. Consult the WORKSPACE on how to use it."""

load("//common:repo.bzl", "tf_mirror_urls")
load(
    "//gpu:nvidia_common_rules.bzl",
    "OS_ARCH_DICT",
    "create_build_file",
    "create_dummy_build_file",
    "create_version_file",
    "get_archive_name",
    "get_cuda_version",
    "get_env_var",
    "get_lib_name_to_version_dict",
    "get_local_templates",
    "get_major_library_version",
    "get_version_and_template_lists",
    "use_local_redist_path",
)
load(
    "//gpu/cuda:cuda_redist_versions.bzl",
    "CUDA_NCCL_WHEELS",
    "REDIST_VERSIONS_TO_BUILD_TEMPLATES",
)

def _use_downloaded_nccl_wheel(repository_ctx):
    # buildifier: disable=function-docstring-args
    """ Downloads NCCL wheel and inits hermetic NCCL repository."""
    cuda_version = get_cuda_version(repository_ctx)
    nccl_version = get_env_var(repository_ctx, "HERMETIC_NCCL_VERSION")
    major_version = ""
    if not cuda_version:
        # If no CUDA version is found, comment out cc_import targets.
        create_dummy_build_file(repository_ctx, cuda_version, is_local_redist = False)
        create_version_file(repository_ctx, major_version)
        return

    # Download archive only when GPU config is used.
    target_arch = get_env_var(repository_ctx, "CUDA_REDIST_TARGET_PLATFORM")
    if target_arch:
        if target_arch in OS_ARCH_DICT.keys():
            arch = OS_ARCH_DICT[target_arch]
        else:
            fail(
                "Unsupported architecture: {arch}, use one of {supported}".format(
                    arch = target_arch,
                    supported = OS_ARCH_DICT.keys(),
                ),
            )
    else:
        arch = OS_ARCH_DICT[repository_ctx.os.arch]

    cuda_major_version = cuda_version.split(".")[0]
    dict_key = "cuda{cuda_major_version}-{arch}-nccl-{nccl_version}".format(
        cuda_major_version = cuda_major_version,
        arch = arch,
        nccl_version = nccl_version,
    )
    supported_versions = repository_ctx.attr.url_dict.keys()
    if dict_key not in supported_versions:
        fail(
            ("The supported NCCL versions are {supported_versions}." +
             " Please provide a supported version in HERMETIC_CUDA_VERSION" +
             " and HERMETIC_NCCL_VERSION environment variables or add NCCL" +
             " distribution for CUDA major version={version}, OS={arch}" +
             " and NCCL={nccl_version}.")
                .format(
                supported_versions = supported_versions,
                version = cuda_major_version,
                arch = arch,
                nccl_version = nccl_version,
            ),
        )
    sha256 = repository_ctx.attr.sha256_dict[dict_key]
    url = repository_ctx.attr.url_dict[dict_key]

    archive_name = get_archive_name(url)
    file_name = archive_name + ".zip"

    print("Downloading and extracting {}".format(url))  # buildifier: disable=print
    repository_ctx.download(
        url = tf_mirror_urls(url),
        output = file_name,
        sha256 = sha256,
    )
    repository_ctx.extract(
        archive = file_name,
        stripPrefix = repository_ctx.attr.strip_prefix,
    )
    repository_ctx.delete(file_name)

    lib_name_to_version_dict = get_lib_name_to_version_dict(repository_ctx)
    major_version = get_major_library_version(
        repository_ctx,
        lib_name_to_version_dict,
    )
    create_build_file(
        repository_ctx,
        cuda_version,
        lib_name_to_version_dict,
        major_version,
        is_local_redist = False,
    )

    create_version_file(repository_ctx, major_version)

def _cuda_nccl_repo_impl(repository_ctx):
    local_nccl_path = get_env_var(repository_ctx, "LOCAL_NCCL_PATH")
    if local_nccl_path:
        use_local_redist_path(repository_ctx, local_nccl_path, repository_ctx.attr.local_source_dirs)
    else:
        _use_downloaded_nccl_wheel(repository_ctx)

cuda_nccl_repo = repository_rule(
    implementation = _cuda_nccl_repo_impl,
    attrs = {
        "sha256_dict": attr.string_dict(mandatory = True),
        "url_dict": attr.string_dict(mandatory = True),
        "versions": attr.string_list(mandatory = True),
        "build_templates": attr.label_list(mandatory = True),
        "local_build_templates": attr.label_list(mandatory = True),
        "strip_prefix": attr.string(),
        "local_source_dirs": attr.string_list(mandatory = True),
    },
)

def nccl_redist_init_repository(
        cuda_nccl_wheels = CUDA_NCCL_WHEELS,
        redist_versions_to_build_templates = REDIST_VERSIONS_TO_BUILD_TEMPLATES):
    # buildifier: disable=function-docstring-args
    """Initializes NCCL repository."""
    nccl_artifacts_dict = {"sha256_dict": {}, "url_dict": {}}
    for cuda_major_version, nccl_wheels in cuda_nccl_wheels.items():
        for arch in OS_ARCH_DICT.values():
            if arch in nccl_wheels.keys():
                for nccl_version, nccl_wheel in nccl_wheels[arch].items():
                    nccl_artifact_key = "cuda%s-%s-nccl-%s" % (cuda_major_version, arch, nccl_version)
                    nccl_artifacts_dict["sha256_dict"][nccl_artifact_key] = nccl_wheel.get("sha256", "")
                    nccl_artifacts_dict["url_dict"][nccl_artifact_key] = nccl_wheel["url"]
    repo_data = redist_versions_to_build_templates["cuda_nccl"]
    versions, templates = get_version_and_template_lists(
        repo_data["version_to_template"],
    )
    local_templates = get_local_templates(repo_data["local"], templates)
    local_source_dirs = repo_data["local"]["source_dirs"]
    cuda_nccl_repo(
        name = repo_data["repo_name"],
        sha256_dict = nccl_artifacts_dict["sha256_dict"],
        url_dict = nccl_artifacts_dict["url_dict"],
        versions = versions,
        build_templates = templates,
        local_build_templates = local_templates,
        strip_prefix = "nvidia/nccl",
        local_source_dirs = local_source_dirs,
    )
