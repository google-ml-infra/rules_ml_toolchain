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

load("@rules_cc//cc:defs.bzl", "cc_toolchain")

def _generate_toolchain_cppmap_impl(ctx):
    prefix = ctx.attr.workspace_prefix
    if prefix and not prefix.endswith("/"):
        prefix += "/"

    lines = ['module "crosstool" [system] {']

    for f in ctx.files.targets:
        path = f.path

        if "/include/" not in path and "cc/cuda/" not in path:
            continue

        # Apply prefix if file is in the main workspace
        if f.owner.workspace_name == "":
            path = prefix + path

        # Format the line with indentation and wrapper
        formatted_line = '  textual header "{}"'.format(path)
        lines.append(formatted_line)

    lines.append("}")
    content = "\n".join(lines) + "\n"

    ctx.actions.write(
        output = ctx.outputs.out_file,
        content = content,
    )

generate_toolchain_cppmap = rule(
    implementation = _generate_toolchain_cppmap_impl,
    attrs = {
        "targets": attr.label_list(
            mandatory = True,
            allow_files = True,
            doc = "The filegroup or list of targets to include in the module map.",
        ),
        "out_file": attr.output(
            mandatory = True,
            doc = "The name of the output file to generate.",
        ),
        "workspace_prefix": attr.string(
            default = "external/rules_ml_toolchain",
            doc = "Prefix to prepend to files belonging to the current workspace.",
        ),
    },
)

def cc_toolchain_with_cppmap(name, all_files, **kwargs):
    generate_toolchain_cppmap(name = "{}_toolchain_cppmap".format(name), targets = [all_files], out_file = "{}_toolchain.cppmap".format(name))
    cc_toolchain(
        name = name,
        all_files = all_files,
        module_map = "{}_toolchain.cppmap".format(name),
        **kwargs
    )
