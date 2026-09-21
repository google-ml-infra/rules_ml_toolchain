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

"""
Runtime library search directories feature.
"""

load(
    "@rules_cc//cc:action_names.bzl",
    "ACTION_NAMES",
)
load(
    "@rules_cc//cc:cc_toolchain_config_lib.bzl",
    "FeatureInfo",
    "feature",
    "flag_group",
    "flag_set",
    "with_feature_set",
)

def _runtime_library_search_directories_impl(ctx):
    """Returns the runtime_library_search_directories feature.
    
    Returns:
        A feature() object that can be added to the toolchain's features list.
    """
    flag_sets = [
        flag_set(
            actions = [
                ACTION_NAMES.cpp_link_executable,
                ACTION_NAMES.cpp_link_dynamic_library,
                ACTION_NAMES.cpp_link_nodeps_dynamic_library,
                ACTION_NAMES.lto_index_for_executable,
                ACTION_NAMES.lto_index_for_dynamic_library,
                ACTION_NAMES.lto_index_for_nodeps_dynamic_library,
            ],
            flag_groups = [
                flag_group(
                    iterate_over = "runtime_library_search_directories",
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-Xlinker",
                                "-rpath",
                                "-Xlinker",
                                "@loader_path/%{runtime_library_search_directories}",
                            ],
                        ),
                    ],
                    expand_if_available = "runtime_library_search_directories",
                ),
            ],
        ),
    ]

    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            provides = ctx.attr.provides,
            implies = [target.label.name for target in ctx.attr.implies],
            flag_sets = flag_sets,
        ),
    ]

runtime_library_search_directories = rule(
    implementation = _runtime_library_search_directories_impl,
    attrs = {
        "enabled": attr.bool(
            default = False,
            doc = "This feature should be enabled by default.",
        ),
        "provides": attr.string_list(
            default = [],
            doc = "Unique key for which only one provider of a functionality can be enabled any given time.",
        ),
        "implies": attr.label_list(
            default = [],
            doc = "Other features that are automatically enabled with this feature.",
        ),
    },
    provides = [FeatureInfo],
)
