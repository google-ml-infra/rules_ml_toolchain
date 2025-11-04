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

_LLVM_VERSION = "LLVM_VERSION"

def _get_platform_arch(ctx):
    """Gets current platform architecture"""
    if ctx.os.arch == "amd64":
        return "x86_64"
    else:
        return ctx.os.arch

def _is_compatible_arch(ctx):
    """Checks if LLVM compatible with current platform"""
    return ctx.attr.name.endswith(_get_platform_arch(ctx))

def _get_llvm_version_flag(ctx):
    """Returns LLVM version put as environment variable"""
    return get_host_environ(ctx, _LLVM_VERSION)

def _get_llvm_version(ctx):
    """Returns the LLVM version from the LLVM_VERSION repository environment variable, defaulting otherwise"""
    ver = _get_llvm_version_flag(ctx) or ctx.attr.default_version

    if not ver:
        fail("Specify LLVM version in .bazelrc file. Example: --repo_env=LLVM_VERSION=21")

    return ver

def _get_llvm_label(ctx, ver):
    """Returns the LLVM label for the specified version"""
    llvm_dict = ctx.attr.versions
    for llvm_label in llvm_dict.keys():
        if llvm_dict[llvm_label] == ver:
            return llvm_label

    return None

def _create_version_file(ctx, major_version):
    """Writes the LLVM version to the version.bzl file"""
    ctx.file(
        "version.bzl",
        "VERSION = \"{}\"".format(major_version),
    )

def _llvm_impl(ctx):
    if not _is_compatible_arch(ctx):
        _create_version_file(ctx, "")
        ctx.file("BUILD", "")
        return

    ver = _get_llvm_version(ctx)
    llvm_label = _get_llvm_label(ctx, ver)
    if not llvm_label:
        fail("Ensure LLVM {} support is added prior to use. Supported versions: {}"
            .format(ver, ", ".join(ctx.attr.versions.values())))

    _create_version_file(ctx, ver)

    ctx.template(
        "BUILD",
        ctx.attr.build_file_tpl,
        {
            "%{llvm_repo_name}": llvm_label.repo_name,
        },
    )

llvm = repository_rule(
    implementation = _llvm_impl,
    attrs = {
        "default_version": attr.string(),
        "versions": attr.label_keyed_string_dict(
            allow_files = True,
            mandatory = True,
        ),
        "build_file_tpl": attr.label(mandatory = True),
    },
)
