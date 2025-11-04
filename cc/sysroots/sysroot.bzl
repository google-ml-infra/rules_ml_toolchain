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

load(
    "//third_party/remote_config:common.bzl",
    "get_host_environ",
)

_SYSROOT_DIST = "SYSROOT_DIST"

def _get_sysroot_dist_flag(ctx):
    """Returns sysroot distribution put as environment variable"""
    return get_host_environ(ctx, _SYSROOT_DIST)

def _get_sysroot_dist(ctx):
    """Returns the sysroot distribution from the SYSROOT_DIST repository environment variable, defaulting otherwise"""

    dist = _get_sysroot_dist_flag(ctx) or ctx.attr.default_dist

    if not dist:
        fail("Specify SYSROOT_DIST in .bazelrc file. Example: --repo_env=SYSROOT_DIST=linux_glibc_2_31")

    return dist

def _get_sysroot_label(ctx, ver):
    """Returns the sysroot label for the specified version"""
    sysroot_dict = ctx.attr.dists
    for sysroot_label in sysroot_dict.keys():
        if sysroot_dict[sysroot_label] == ver:
            return sysroot_label

    return None

def _sysroot_impl(ctx):
    ver = _get_sysroot_dist(ctx)
    sysroot_label = _get_sysroot_label(ctx, ver)
    if not sysroot_label:
        fail("Ensure SYSROOT_DIST {} support is added prior to use. Supported distributions: {}"
            .format(ver, ", ".join(ctx.attr.dists.values())))

    ctx.template(
        "BUILD",
        ctx.attr.build_file_tpl,
        {
            "%{sysroot_repo_name}": sysroot_label.repo_name,
        },
    )

sysroot = repository_rule(
    implementation = _sysroot_impl,
    attrs = {
        "default_dist": attr.string(),
        "dists": attr.label_keyed_string_dict(
            allow_files = True,
            mandatory = True,
        ),
        "build_file_tpl": attr.label(mandatory = True),
    },
)
