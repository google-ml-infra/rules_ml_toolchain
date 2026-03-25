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

load("//rules_pywrap:pywrap.bzl", "pywrap_common_library", "pywrap_library")

pywrap_library(
    name = "pybind_external_aggregated",
    pywrap_lib_filter = "//py/rules_pywrap/tests:third_library",
    # Should be generated in final version
    deps = [
        "//py/rules_pywrap/tests",
        "//py/rules_pywrap/tests:pybind_cc_only",
        "//py/rules_pywrap/tests:pybind_copy",
        "//py/rules_pywrap/tests/sub_pybind:relative_import_lib",
    ],
)

pywrap_common_library(
    name = "pybind_external_aggregated_internal",
    dep = ":pybind_external_aggregated",
)

py_test(
    name = "pybind_external_py_test",
    srcs = ["pybind_external_py_test.py"],
    visibility = ["//:__pkg__"],
    deps = [
        ":pybind_external_aggregated",
        "//py/rules_pywrap/tests/sub_pybind:relative_import_lib",
    ],
)

py_test(
    name = "pybind_pywrap_external_py_test",
    srcs = ["pybind_external_py_test.py"],
    main = "pybind_external_py_test.py",
    visibility = ["//:__pkg__"],
    deps = [
        "//pywrap_external:pywrap_external_aggregated",
        "//py/rules_pywrap/tests/sub_pybind:relative_import_lib",
    ],
)

py_test(
    name = "pywrap_external_aggregated_binaries_test",
    srcs = ["pywrap_external_aggregated_binaries_test.py"],
    args = [
        "--wheel-locations=$(location {})".format(
            "//pywrap_external:pywrap_external_aggregated_binaries.json",
        ),
    ],
    visibility = ["//:__pkg__"],
    data = [
        "//pywrap_external:pywrap_external_aggregated_binaries",
        "//pywrap_external:pywrap_external_aggregated_binaries.json",
    ],
)

py_binary(
    name = "pybind_external_py_binary",
    srcs = ["pybind_external_py_test.py"],
    main = "pybind_external_py_test.py",
    deps = [
        ":pybind_external_aggregated",
    ],
)

py_binary(
    name = "pybind_pywrap_external_py_binary",
    srcs = ["pybind_external_py_test.py"],
    main = "pybind_external_py_test.py",
    deps = [
        "//pywrap_external:pywrap_external_aggregated",
    ],
)
