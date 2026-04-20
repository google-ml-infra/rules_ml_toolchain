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

"""Custom sysroot feature for local system sysroot.

This feature sets --sysroot only for linking, not compilation.
This allows using hermetic C++ headers while linking against system libraries
for ABI compatibility.
"""

load(
    "@rules_cc//cc:action_names.bzl",
    "ALL_CC_COMPILE_ACTION_NAMES",
    "ALL_CC_LINK_ACTION_NAMES",
)
load(
    "@rules_cc//cc:cc_toolchain_config_lib.bzl",
    "FeatureInfo",
    "feature",
    "flag_group",
    "flag_set",
)

def _local_sysroot_feature_impl(ctx):
    """Implementation for local sysroot feature.

    Simply sets --sysroot=/ to use the actual system root.
    No repository, no file copying, just use the system directly.
    """

    flag_sets = [
        # Set --sysroot=/ for both compilation and linking
        # This uses actual system headers and libraries
        # With hermetic_libraries feature disabled, clang uses default system paths
        flag_set(
            actions = ALL_CC_COMPILE_ACTION_NAMES + ALL_CC_LINK_ACTION_NAMES,
            flag_groups = [
                flag_group(
                    flags = [
                        "--sysroot=/",
                    ],
                ),
            ],
        ),
    ]

    return feature(
        name = ctx.label.name,
        enabled = ctx.attr.enabled,
        provides = ctx.attr.provides,
        implies = [label.name for label in ctx.attr.implies],
        flag_sets = flag_sets,
    )

local_sysroot_feature = rule(
    implementation = _local_sysroot_feature_impl,
    attrs = {
        "enabled": attr.bool(default = False),
        "provides": attr.string_list(),
        "implies": attr.string_list(),
    },
    provides = [FeatureInfo],
)
