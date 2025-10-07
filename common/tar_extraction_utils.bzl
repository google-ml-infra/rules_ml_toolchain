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
    "execute",
    "get_bash_bin",
)


def extract_tar_with_non_hermetic_tar_tool(repository_ctx, file_name, strip_prefix):
    if not (repository_ctx.os.name == "linux" and hasattr(repository_ctx.attr, "tar_tool")):
        repository_ctx.extract(
            archive = file_name,
            stripPrefix = strip_prefix,
        )
        return
    tar_tool_path = repository_ctx.path(repository_ctx.attr.tar_tool)
    if file_name.endswith(".xz"):
        if not hasattr(repository_ctx.attr, "xz_tool"):
            repository_ctx.extract(
                archive = file_name,
                stripPrefix = strip_prefix,
            )
            return
        xz_tool_path = repository_ctx.path(repository_ctx.attr.xz_tool)
        compress_program_option = "--use-compress-program=%s" % xz_tool_path
    else:
        compress_program_option = ""

    extract_command = "{tar_tool_path} -xvf {archive} --strip-components=1 {compress_program_option}".format(
        tar_tool_path = tar_tool_path,
        archive = file_name,
        compress_program_option = compress_program_option
    )
    exec_result = execute(repository_ctx,
        [get_bash_bin(repository_ctx), "-c", extract_command],
    )
    if exec_result.return_code != 0:
        print("Couldn't extract {archive} using tar, falling back to default behavior".format(archive = file_name))
        repository_ctx.extract(
            archive = file_name,
            stripPrefix = strip_prefix,
        )

def _tool_archive_impl(repository_ctx):
    if repository_ctx.os.arch == "aarch64":
        repository_ctx.download_and_extract(
            sha256 = repository_ctx.attr.linux_aarch64_sha256,
            stripPrefix = repository_ctx.attr.linux_aarch64_strip_prefix,
            url = repository_ctx.attr.linux_aarch64_urls,
        )
    else:
        repository_ctx.download_and_extract(
            sha256 = repository_ctx.attr.linux_x86_64_sha256,
            stripPrefix = repository_ctx.attr.linux_x86_64_strip_prefix,
            url = repository_ctx.attr.linux_x86_64_urls,
        )
    repository_ctx.file("BUILD.bazel", "")

tool_archive = repository_rule(
    implementation = _tool_archive_impl,
    attrs = {
        "linux_x86_64_urls": attr.string_list(),
        "linux_x86_64_sha256": attr.string(),
        "linux_x86_64_strip_prefix": attr.string(),
        "linux_aarch64_urls": attr.string_list(),
        "linux_aarch64_sha256": attr.string(),
        "linux_aarch64_strip_prefix": attr.string(),
    },
)
