load("//rules_pywrap:pywrap.bzl", "pywrap_binaries", "pywrap_library")

pywrap_library(
    name = "pywrap_external_aggregated",
    common_lib_filters = {
        "py/rules_pywrap/tests/framework": "//py/rules_pywrap/tests:fifth_library",
    },
    common_lib_versions = {
        "py/rules_pywrap/tests/framework": "2",
    },
    pywrap_lib_filter = "//py/rules_pywrap/tests:third_library",
    starlark_only_deps = [
        "//py/rules_pywrap/tests:pybind_with_starlark_only",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//py/rules_pywrap/tests",
        "//py/rules_pywrap/tests:pybind_cc_only",
        "//py/rules_pywrap/tests:pybind_copy",
        "//py/rules_pywrap/tests/sub_pybind:relative_import_lib",
    ],
)

pywrap_binaries(
    name = "pywrap_external_aggregated_binaries",
    dep = ":pywrap_external_aggregated",
    visibility = ["//visibility:public"],
)
