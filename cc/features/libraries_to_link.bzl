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

# TODO: Return "no_solib_rpaths" logic
"""Runtime library search directories feature.

This feature overrides the default runtime_library_search_directories behavior
to ensure proper with_features support for no_solib_rpaths.

The issue: The global hermetic toolchain embeds runtime_library_search_directories
flag_sets directly in action_config, which prevents Bazel from properly evaluating
with_features conditions like not_features = ["no_solib_rpaths"].

The fix: Create a standalone feature with the same flag_sets but as a proper feature,
so that with_features conditions are correctly evaluated.
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
    "variable_with_value",
)

def _libraries_to_link_feature_impl(ctx):
    """Returns the libraries_to_link_feature feature.

    Returns:
        A feature() object that can be added to the toolchain's features list.
    """

    libraries_to_link_common_flag_groups = [
        flag_group(
            flags = ["-Wl,-whole-archive"],
            expand_if_true =
                "libraries_to_link.is_whole_archive",
            expand_if_equal = variable_with_value(
                name = "libraries_to_link.type",
                value = "static_library",
            ),
        ),
        flag_group(
            flags = ["%{libraries_to_link.object_files}"],
            iterate_over = "libraries_to_link.object_files",
            expand_if_equal = variable_with_value(
                name = "libraries_to_link.type",
                value = "object_file_group",
            ),
        ),
        flag_group(
            flags = ["%{libraries_to_link.name}"],
            expand_if_equal = variable_with_value(
                name = "libraries_to_link.type",
                value = "object_file",
            ),
        ),
        flag_group(
            flags = ["%{libraries_to_link.name}"],
            expand_if_equal = variable_with_value(
                name = "libraries_to_link.type",
                value = "interface_library",
            ),
        ),
        flag_group(
            flags = ["%{libraries_to_link.name}"],
            expand_if_equal = variable_with_value(
                name = "libraries_to_link.type",
                value = "static_library",
            ),
        ),
        flag_group(
            flags = ["-l%{libraries_to_link.name}"],
            expand_if_equal = variable_with_value(
                name = "libraries_to_link.type",
                value = "dynamic_library",
            ),
        ),
        flag_group(
            flags = ["-l:%{libraries_to_link.name}"],
            expand_if_equal = variable_with_value(
                name = "libraries_to_link.type",
                value = "versioned_dynamic_library",
            ),
        ),
        flag_group(
            flags = ["-Wl,-no-whole-archive"],
            expand_if_true = "libraries_to_link.is_whole_archive",
            expand_if_equal = variable_with_value(
                name = "libraries_to_link.type",
                value = "static_library",
            ),
        ),
    ]

    flag_sets = [
        flag_set(
            actions = [
                ACTION_NAMES.cpp_link_executable,
                ACTION_NAMES.cpp_link_dynamic_library,
                ACTION_NAMES.lto_index_for_executable,
                ACTION_NAMES.lto_index_for_dynamic_library,
                ACTION_NAMES.lto_index_for_nodeps_dynamic_library,
            ],
            flag_groups = [
                flag_group(
                    iterate_over = "libraries_to_link",
                    flag_groups = [
                        flag_group(
                            flags = ["-Wl,--start-lib"],
                            expand_if_equal = variable_with_value(
                                name = "libraries_to_link.type",
                                value = "object_file_group",
                            ),
                        ),
                    ] + libraries_to_link_common_flag_groups + [
                        flag_group(
                            flags = ["-Wl,--end-lib"],
                            expand_if_equal = variable_with_value(
                                name = "libraries_to_link.type",
                                value = "object_file_group",
                            ),
                        ),
                    ],
                    expand_if_available = "libraries_to_link",
                ),
                flag_group(
                    flags = ["-Wl,@%{thinlto_param_file}"],
                    expand_if_true = "thinlto_param_file",
                ),
            ],
        ),
        flag_set(
            actions = [ACTION_NAMES.cpp_link_nodeps_dynamic_library],
            flag_groups = [
                flag_group(
                    iterate_over = "libraries_to_link",
                    flag_groups = libraries_to_link_common_flag_groups,
                ),
                flag_group(
                    flags = ["-Wl,@%{thinlto_param_file}"],
                    expand_if_true = "thinlto_param_file",
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

libraries_to_link_feature = rule(
    implementation = _libraries_to_link_feature_impl,
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
