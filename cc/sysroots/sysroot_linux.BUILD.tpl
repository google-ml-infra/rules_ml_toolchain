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

alias(
    name = "sysroot",
    actual = "@@%{sysroot_repo_name}//:sysroot",
    visibility = ["//visibility:public"],
)

alias(
    name = "startup_libs",
    actual = "@@%{sysroot_repo_name}//:startup_libs",
    visibility = ["//visibility:public"],
)

alias(
    name = "includes_c",
    actual = "@@%{sysroot_repo_name}//:includes_c",
    visibility = ["//visibility:public"],
)

alias(
    name = "includes",
    actual = "@@%{sysroot_repo_name}//:includes",
    visibility = ["//visibility:public"],
)

alias(
    name = "includes_system",
    actual = "@@%{sysroot_repo_name}//:includes_system",
    visibility = ["//visibility:public"],
)

alias(
    name = "syslibs",
    actual = "@@%{sysroot_repo_name}//:syslibs",
    visibility = ["//visibility:public"],
)

alias(
    name = "pthread",
    actual = "@@%{sysroot_repo_name}//:pthread",
    visibility = ["//visibility:public"],
)

alias(
    name = "openmp",
    actual = "@@%{sysroot_repo_name}//:openmp",
    visibility = ["//visibility:public"],
)

alias(
    name = "openmp_import",
    actual = "@@%{sysroot_repo_name}//:openmp_import",
    visibility = ["//visibility:public"],
)

alias(
    name = "openmp_copyright",
    actual = "@@%{sysroot_repo_name}//:openmp_copyright",
    visibility = ["//visibility:public"],
)
