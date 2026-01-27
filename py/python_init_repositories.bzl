# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Hermetic Python initialization. Consult the WORKSPACE on how to use it."""

load("@rules_python//python:repositories.bzl", "py_repositories")
load("//py:python_repo.bzl", "python_repository")

def python_init_repositories(
        requirements = {},
        local_wheel_workspaces = [],
        local_wheel_dist_folder = None,
        default_python_version = None,
        local_wheel_inclusion_list = ["*"],
        local_wheel_exclusion_list = []):
    python_repository(
        name = "python_version_repo",
        requirements_versions = requirements.keys(),
        requirements_locks = requirements.values(),
        local_wheel_workspaces = local_wheel_workspaces,
        local_wheel_dist_folder = local_wheel_dist_folder,
        default_python_version = default_python_version,
        local_wheel_inclusion_list = local_wheel_inclusion_list,
        local_wheel_exclusion_list = local_wheel_exclusion_list,
    )
    py_repositories()
