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

def _build_file(ctx, build_file):
    """Utility function for writing a BUILD file.

    Args:
      ctx: The repository context of the repository rule calling this utility function.
      build_file: The file to use as the BUILD file for this repository. This attribute is an absolute label.
    """

    ctx.file("BUILD.bazel", ctx.read(build_file))

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

    if ctx.name == "level_zero":
        _handle_level_zero(ctx)

    build_template = ctx.attr.build_templates[dist_key]
    _build_file(ctx, Label(build_template))

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
    },
)
