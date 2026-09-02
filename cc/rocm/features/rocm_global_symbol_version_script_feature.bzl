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

"""ROCm global symbol version script feature rule."""

load(
    "@rules_cc//cc:action_names.bzl",
    "ACTION_NAME_GROUPS",
)
load(
    "@rules_cc//cc:cc_toolchain_config_lib.bzl",
    "FeatureInfo",
    "flag_group",
    "flag_set",
    _feature = "feature",
)

def _rocm_global_symbol_version_script_feature_impl(ctx):
    """Implementation of the rocm_global_symbol_version_script_feature rule."""

    # Get the path from the label
    version_script_file = ctx.file.version_script
    version_script_path = version_script_file.path

    return _feature(
        name = ctx.label.name,
        enabled = ctx.attr.enabled,
        flag_sets = [
            flag_set(
                actions = ACTION_NAME_GROUPS.all_cc_link_actions,
                flag_groups = [
                    flag_group(
                        flags = ["-Wl,--version-script," + version_script_path],
                    ),
                ],
            ),
        ],
    )

rocm_global_symbol_version_script_feature = rule(
    implementation = _rocm_global_symbol_version_script_feature_impl,
    attrs = {
        "enabled": attr.bool(
            default = True,
            doc = "Whether this feature is enabled by default.",
        ),
        "version_script": attr.label(
            mandatory = True,
            allow_single_file = True,
            doc = "Label pointing to the global symbol version script file.",
        ),
    },
    provides = [FeatureInfo],
    doc = """
Creates a toolchain feature for ROCm global symbol versioning.

This feature adds a linker version script to prevent LLVM symbol clashes
between XLA's LLVM and ROCm's libLLVM.so.

Example usage:
    rocm_global_symbol_version_script_feature(
        name = "rocm_global_symbol_version_script",
        version_script = "@config_rocm_hipcc//rocm:global_symbol_version.lds",
        enabled = select({
            "//common:is_rocm_global_symbol_version_enabled": True,
            "//conditions:default": False,
        }),
    )
""",
)
