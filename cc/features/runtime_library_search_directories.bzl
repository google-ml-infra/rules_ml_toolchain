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
    "feature",
    "flag_group",
    "flag_set",
    "with_feature_set",
)

def runtime_library_search_directories_feature():
    """Returns the runtime_library_search_directories feature.

    This ensures with_features conditions (specifically not_features = ["no_solib_rpaths"])
    are properly evaluated.

    Returns:
        A feature() object that can be added to the toolchain's features list.
    """
    return feature(
        name = "runtime_library_search_directories",
        enabled = True,
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
                                    "-Wl,-rpath,$EXEC_ORIGIN/%{runtime_library_search_directories}",
                                ],
                                expand_if_true = "is_cc_test",
                            ),
                            flag_group(
                                flags = [
                                    "-Wl,-rpath,$ORIGIN/%{runtime_library_search_directories}",
                                ],
                                expand_if_false = "is_cc_test",
                            ),
                        ],
                        expand_if_available = "runtime_library_search_directories",
                    ),
                ],
                with_features = [
                    with_feature_set(
                        features = ["static_link_cpp_runtimes"],
                        not_features = ["no_solib_rpaths"],
                    ),
                ],
            ),
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
                                    "-Wl,-rpath,$ORIGIN/%{runtime_library_search_directories}",
                                ],
                            ),
                        ],
                        expand_if_available = "runtime_library_search_directories",
                    ),
                ],
                with_features = [
                    with_feature_set(
                        not_features = ["static_link_cpp_runtimes", "no_solib_rpaths"],
                    ),
                ],
            ),
        ],
    )

def _runtime_library_search_directories_impl(ctx):
    return [runtime_library_search_directories_feature()]

runtime_library_search_directories = rule(
    implementation = _runtime_library_search_directories_impl,
    provides = [],
)
