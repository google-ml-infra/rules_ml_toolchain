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

def _get_file_name(url):
    last_slash_index = url.rfind("/")
    return url[last_slash_index + 1:]

def _download_distribution(ctx, dist):
    # buildifier: disable=function-docstring-args
    """Downloads and extracts Intel distribution."""

    url = dist[0]
    file_name = _get_file_name(url)
    print("Downloading {}".format(url))  # buildifier: disable=print
    ctx.download(
        url = url,
        output = file_name,
        sha256 = dist[1],
    )

    strip_prefix = dist[2]

    print("Extracting {} with strip prefix '{}'".format(file_name, strip_prefix))  # buildifier: disable=print
    ctx.extract(
        archive = file_name,
        stripPrefix = strip_prefix,
    )

    ctx.delete(file_name)

def _get_oneapi_version(ctx):
    return ctx.getenv("ONEAPI_VERSION", "")

def _get_os(ctx):
    return ctx.getenv("OS", "")

def _get_dist_key(ctx):
    oneapi_version = _get_oneapi_version(ctx)
    os_id = _get_os(ctx)
    if not oneapi_version:
        oneapi_version = "2025.1"
    if not os_id:
        os_id = "ubuntu_24.10"

    return "{}_{}".format(os_id, oneapi_version)

def _get_dist_version(dist_key):
    return dist_key[dist_key.rfind("_") + 1:]

_ONEAPI_BUILD_SUBSTITUTIONS = {
    "2025.1": {
        "%{advisor_version}": "2021.15",
        "%{clang_version}": "20",
        "%{extra_lib_src_glob}": "__unused_oneapi_lib__",
        "%{ipp_version}": "2022.1",
        "%{libsycl_version}": "8",
        "%{mpi_version}": "2021.15",
        "%{oneapi_lib_paths}": ":compiler/2025.1/lib,:compiler/2025.1/compiler/lib/intel64_lin",
        "%{oneapi_version}": "2025.1",
        "%{tbb_version}": "2022.1",
        "%{tcm_version}": "1.3",
        "%{umf_version}": "0.10",
        "%{vtune_version}": "2025.3",
    },
    "2026.0": {
        "%{advisor_version}": "2026.0",
        "%{clang_version}": "22",
        "%{extra_lib_src_glob}": "2026.0/lib/libur_adapter_level_zero_v2.so*",
        "%{ipp_version}": "2026.0",
        "%{libsycl_version}": "9",
        "%{mpi_version}": "2021.18",
        "%{oneapi_lib_paths}": ":2026.0/lib,:compiler/2026.0/lib,:compiler/2026.0/opt/compiler/lib",
        "%{oneapi_version}": "2026.0",
        "%{tbb_version}": "2023.0",
        "%{tcm_version}": "1.5",
        "%{umf_version}": "1.1",
        "%{vtune_version}": "2026.0",
    },
}

def _get_build_substitutions(ctx, dist_key):
    if ctx.name != "oneapi":
        return {}

    version = _get_dist_version(dist_key)
    if version not in _ONEAPI_BUILD_SUBSTITUTIONS:
        fail("No oneAPI BUILD substitutions found for version {}".format(version))

    return _ONEAPI_BUILD_SUBSTITUTIONS[version]

def _build_file(ctx, build_template, substitutions):
    """Utility function for writing a BUILD file from a template.

    Args:
      ctx: The repository context of the repository rule calling this utility function.
      build_template: The template file to use as the BUILD file for this repository. This attribute is an absolute label.
      substitutions: Template substitutions for the BUILD file.
    """

    ctx.template("BUILD.bazel", build_template, substitutions)

def _handle_level_zero(ctx):
    # Symlink for includes backward compatibility (example: #include <level_zero/ze_api.h>)
    ctx.symlink("include", "level_zero")

def _use_downloaded_archive(ctx):
    # buildifier: disable=function-docstring-args
    """ Downloads redistribution and initializes hermetic repository."""
    dist_key = _get_dist_key(ctx)

    dist = ctx.attr.distrs[dist_key]

    if not dist:
        fail(
            ("Version {version} for platform {platform} is not supported.")
                .format(version = _get_oneapi_version(ctx), platform = _get_os(ctx)),
        )

    _download_distribution(ctx, dist)

    if ctx.attr.is_level_zero:
        _handle_level_zero(ctx)

    build_template = Label(ctx.attr.build_templates[dist_key])
    substitutions = _get_build_substitutions(ctx, dist_key)
    _build_file(ctx, build_template, substitutions)

def _dist_repo_impl(ctx):
    local_dist_path = None
    if local_dist_path:
        # TODO: Implement SYCL non-hermetic build
        fail("SYCL non-hermetic build hasn't supported")

    else:
        _use_downloaded_archive(ctx)

dist_repo = repository_rule(
    implementation = _dist_repo_impl,
    attrs = {
        "distrs": attr.string_list_dict(mandatory = True),
        "build_templates": attr.string_dict(mandatory = True),
        "is_level_zero": attr.bool(default = False),
    },
)
