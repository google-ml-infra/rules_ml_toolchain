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

load("//rules_pywrap:pywrap.bzl", "pywrap_binaries", "pywrap_library")

pywrap_library(
    name = "pywrap_external_aggregated",
    common_lib_filters = {
        "py/rules_pywrap/tests/framework": "//py/rules_pywrap/tests/pybind:fifth_library",
    },
    common_lib_versions = {
        "py/rules_pywrap/tests/framework": "2",
    },
    pywrap_lib_filter = "//py/rules_pywrap/tests/pybind:third_library",
    starlark_only_deps = [
        "//py/rules_pywrap/tests/pybind:pybind_with_starlark_only",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//py/rules_pywrap/tests/pybind:tests",
        "//py/rules_pywrap/tests/pybind:pybind_cc_only",
        "//py/rules_pywrap/tests/pybind:pybind_copy",
        "//py/rules_pywrap/tests/sub_pybind:relative_import_lib",
    ],
)

pywrap_binaries(
    name = "pywrap_external_aggregated_binaries",
    dep = ":pywrap_external_aggregated",
    visibility = ["//visibility:public"],
)
