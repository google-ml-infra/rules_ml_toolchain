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
    "realpath",
    "which",
)

def extract_tar_with_non_hermetic_tar_tool(repository_ctx, file_name, strip_prefix):
    if repository_ctx.os.name != "linux":
        repository_ctx.extract(
            archive = file_name,
            stripPrefix = strip_prefix,
        )
        return

    tar_tool_path = _get_tool_path(repository_ctx, "tar")
    if not tar_tool_path:
        repository_ctx.extract(
            archive = file_name,
            stripPrefix = strip_prefix,
        )
        return
    if file_name.endswith(".xz"):
        # Multithreading was introduced in version 5.8.1.
        xz_tool_path = _get_tool_path(repository_ctx, "xz", [5, 8, 1])
        if not xz_tool_path:
            repository_ctx.extract(
                archive = file_name,
                stripPrefix = strip_prefix,
            )
            return
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

def _is_above_min_version(actual_ver, min_ver):
    for i in range(0, len(min_ver)):
        actual_ver_int = int(actual_ver[i])
        if actual_ver_int < min_ver[i]:
            return False
        if actual_ver_int > min_ver[i]:
            return True
    return True

def _get_tool_version(repository_ctx, path, bash_bin = None):
    if bash_bin == None:
        bash_bin = get_bash_bin(repository_ctx)

    return execute(repository_ctx, [bash_bin, "-c", "\"%s\" --version" % path]).stdout.strip()

def _get_tool_path(repository_ctx, tool_name, min_version = None):
    tool = which(repository_ctx, tool_name, allow_failure = True)
    if not tool:
        return None

    if min_version:
        tool_version_result = _get_tool_version(repository_ctx, tool)
        tool_version = tool_version_result.split("\n")[0].split(" ")[-1]
        if not _is_above_min_version(tool_version.split("."), min_version):
            return None

    return realpath(repository_ctx, tool)
