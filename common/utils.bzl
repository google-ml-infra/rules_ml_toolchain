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
    "get_bash_bin",
    "realpath",
    "version",
    "which",
)

def _extract_tar_with_bazel(repository_ctx, file_name, strip_prefix):
    repository_ctx.extract(
        archive = file_name,
        stripPrefix = strip_prefix,
    )

def _is_xz_multithreading_enabled(xz_tool_version_result):
    # Multithreading was introduced in version 5.8.1.
    xz_tool_version = xz_tool_version_result.split("\n")[0].split(" ")[-1]
    (major, minor, patch) = xz_tool_version.split(".")
    if int(major) < 5:
        return False
    if int(major) == 5:
        if int(minor) < 8:
            return False
        elif int(minor) ==8 and int(patch) == 0:
            return False
    return True

def extract_tar_with_tar_tool(repository_ctx, file_name, strip_prefix):
    if repository_ctx.os.name != "linux":
        _extract_tar_with_bazel(repository_ctx, file_name, strip_prefix)
        return

    tar_tool = which(repository_ctx, "tar", allow_failure = True)
    xz_tool = which(repository_ctx, "xz", allow_failure = True)
    if not (tar_tool and xz_tool):
        _extract_tar_with_bazel(repository_ctx, file_name, strip_prefix)
        return
    xz_tool_version_result = version(repository_ctx, xz_tool)
    if not _is_xz_multithreading_enabled(xz_tool_version_result):
        _extract_tar_with_bazel(repository_ctx, file_name, strip_prefix)
        return
    tar_tool_path = realpath(repository_ctx, tar_tool)
    xz_tool_path = realpath(repository_ctx, xz_tool)

    if file_name.endswith(".xz"):
        compress_program_option = "--use-compress-program=%s" % xz_tool_path
    else:
        compress_program_option = ""
    extract_command = "{tar_tool_path} -xvf {archive} --strip-components=1 {compress_program_option}".format(
        tar_tool_path = tar_tool_path,
        archive = file_name,
        compress_program_option = compress_program_option
    )
    exec_result = repository_ctx.execute(
        [get_bash_bin(repository_ctx), "-c", extract_command],
    )
    if exec_result.return_code != 0:
        print("Couldn't extract {archive} using tar, falling back to default behavior".format(archive = file_name))
        _extract_tar_with_bazel(repository_ctx, file_name, strip_prefix)

