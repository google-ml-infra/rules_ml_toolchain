# Copyright 2026 Google LLC
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

def _get_dir_path(rctx, path_str):
    path = rctx.workspace_root.get_child(path_str)
    if not path.is_dir:
        fail(
            ("The repository's path is \"%s\" (absolute: \"%s\") but it is not " +
             "a directory.") % (path_str, path),
        )
    return path

def _macos_sdk_impl(rctx):
    os_name = rctx.os.name

    sdk_path = rctx.getenv("MACOS_SYSROOT_PATH", "")
    if not sdk_path:
        developer_dir = rctx.getenv("DEVELOPER_DIR", "").strip()
        if os_name.startswith("mac"):
            args = [
                "env",
                "-i",
                "DEVELOPER_DIR={}".format(developer_dir),
            ] if developer_dir else []

            args += [
                "xcrun",
                "--show-sdk-path",
            ]

            res = rctx.execute(args)
            if res.return_code != 0:
                fail("Failed to find macOS SDK via xcrun: " + res.stderr)
            sdk_path = res.stdout.strip()

        elif os_name.startswith("linux"):
            sdk_path = rctx.attr.default_path
        else:
            fail("Unsupported operation system '" + os_name + "' for macOS targets build.")

    sub_paths = _get_dir_path(rctx, sdk_path).readdir()
    for path in sub_paths:
        rctx.symlink(path, path.basename)

    rctx.symlink(rctx.path(rctx.attr.build_file), "BUILD.bazel")

macos_sdk = repository_rule(
    implementation = _macos_sdk_impl,
    local = True,
    environ = ["MACOS_SYSROOT_PATH"],
    attrs = {
        "build_file": attr.label(
            doc = "A file to use as a BUILD file for this repository",
            mandatory = True,
        ),
        "default_path": attr.string(
            doc = "Default path to macOS SDK",
            mandatory = True,
        ),
    },
)
