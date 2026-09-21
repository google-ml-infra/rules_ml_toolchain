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

def _xcode_macos_impl(ctx):
    developer_dir = ctx.os.environ.get("DEVELOPER_DIR", "").strip()

    args = ["env",
            "-i",
            "DEVELOPER_DIR={}".format(developer_dir)
        ] if developer_dir else []

    args += [
        "xcode-select",
        "-p"
    ]

    cmd = ctx.execute(args)
    if cmd.return_code != 0:
        fail("Failed to find macOS XCODE via xcode-select: " + cmd.stderr)
    xcode_path = cmd.stdout.strip()

    xcode_toolchain_path = xcode_path + "/Toolchains/XcodeDefault.xctoolchain/"

    ctx.template(
        "BUILD",
        ctx.attr.build_file_tpl,
        { },
    )

    links = ["usr"]
    for link in links:
        ctx.symlink(xcode_toolchain_path + "/" + link, link)

xcode_macos = repository_rule(
    implementation = _xcode_macos_impl,
    local = True,
    environ = ["MACOS_XCODE_LINKER_PATH"],
    attrs = {
        "build_file_tpl": attr.label(
            doc = "A file to use as a BUILD file for this repo.",
            default = Label("@rules_ml_toolchain//cc/llvms:xcode_macos.BUILD.tpl"),
        ),
    },
)