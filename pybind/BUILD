load(
    "//py/rules_pywrap:pywrap.default.bzl",
    "pybind_extension",
    "pywrap_binaries",
    "pywrap_common_library",
    "pywrap_library",
)

load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("@rules_cc//cc:cc_import.bzl", "cc_import")
load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("@rules_python//python:py_info.bzl", "PyInfo")
load("@rules_python//python:py_library.bzl", "py_library")
load("@rules_python//python:py_test.bzl", "py_test")

#load("//:pywrap_repositories.bzl", "py_test")
exports_files([
    "pybind_aggregated.def",
    "py_cc_pybind_aggregated.def",
])

#
# Logic shared between python and regular C++ binaries/test
#
cc_library(
    name = "sixth_library",
    srcs = ["sixth_library.cc"],
    hdrs = ["sixth_library.h"],
    features = ["windows_export_all_symbols"],
    linkstatic = True,
    visibility = ["//visibility:public"],
    deps = [":second_library"],
    alwayslink = False,
)

cc_library(
    name = "fifth_library",
    srcs = ["fifth_library.cc"],
    hdrs = ["fifth_library.h"],
    features = ["windows_export_all_symbols"],
    linkstatic = True,
    visibility = ["//visibility:public"],
    deps = [":second_library"],
    alwayslink = False,
)

cc_library(
    name = "fourth_library",
    srcs = ["fourth_library.cc"],
    features = ["windows_export_all_symbols"],
    linkstatic = True,
    deps = [":second_library"],
    alwayslink = False,
)

cc_library(
    name = "third_library",
    srcs = ["third_library.cc"],
    hdrs = ["third_library.h"],
    #    deps = [":second_library"],
    features = ["windows_export_all_symbols"],
    linkstatic = True,
    visibility = ["//visibility:public"],
    alwayslink = False,
)

cc_library(
    name = "second_library",
    srcs = ["second_library.cc"],
    hdrs = ["second_library.h"],
    data = [
        "//data:static_resource.txt",
    ],
    features = ["windows_export_all_symbols"],
    linkstatic = True,
    alwayslink = False,
)

cc_library(
    name = "first_library",
    srcs = ["first_library.cc"],
    hdrs = ["first_library.h"],
    data = [
        "//data:data_binary",
        "//data:static_resource.txt",
    ],
    features = ["windows_export_all_symbols"],
    linkstatic = False,
    deps = [":second_library"],
    alwayslink = False,
)

#
# Regular C++ binaries/tests
#
cc_library(
    name = "regular",
    srcs = ["regular.cc"],
    hdrs = ["regular.h"],
    features = ["windows_export_all_symbols"],
    linkstatic = True,
    deps = [
        ":first_library",
        ":second_library",
    ],
    alwayslink = True,
)

cc_library(
    name = "regular_copy",
    srcs = ["regular_copy.cc"],
    hdrs = ["regular_copy.h"],
    features = ["windows_export_all_symbols"],
    linkstatic = False,
    deps = [
        ":first_library",
        ":second_library",
    ],
    alwayslink = False,
)

# Nodes in transitive closure of this binary:
cc_test(
    name = "regular_cc_test",
    srcs = ["regular_test.cc"],
    visibility = ["//:__pkg__"],
    deps = [
        ":regular",
        ":regular_copy",
        "@gtest//:gtest_main",
    ],
    #    linkstatic = by default will be "True" on windows else "False"
    #    linkstatic = False,
)

#
# Python-specific (pybind) binaries/tests
#
pybind_extension(
    name = "pybind",
    srcs = select({
        "//conditions:default": ["pybind.cc"],
    }),
    common_lib_packages = [
        "",
        "pywrap_external/python",  # non-existent package to test that its Ok
        "pybind_external",
        "pywrap_external",
    ],
    data = [":static_resource.txt"],
    visibility = ["//visibility:public"],
    deps = [
        ":fifth_library",
        ":first_library",
        ":second_library",
        ":third_library",
    ],
    local_defines = ["TARGET_NAME=pybind"],
)

pybind_extension(
    name = "pybind_copy",
    srcs = ["pybind_copy.cc"],
    common_lib_packages = [
        "",
        "pywrap_external",
        "pybind_external",
    ],
    visibility = ["//visibility:public"],
    deps = [
        ":first_library",
        ":second_library",
    ] + select({
        "//conditions:default": [":third_library"],
    }),
    local_defines = ["TARGET_NAME=pybind_copy"],
)

pybind_extension(
    name = "pybind_cc_only",
    visibility = ["//visibility:public"],
    deps = [
        "fourth_library",
    ],
)

pybind_extension(
    name = "pybind_with_starlark_only",
    srcs = ["pybind_with_starlark_only.cc"],
    common_lib_packages = [
        "",
        "pywrap_external",
        "pybind_external",
    ],
    starlark_only = True,
    visibility = ["//visibility:public"],
    deps = [
        ":sixth_library",
    ],
)

py_library(
    name = "py_library_1",
    srcs = [],
    deps = [":pybind"],
)

py_library(
    name = "py_library_2",
    srcs = [],
    # "pybind" is already in py_library1, duplicats "pybind" on purpose
    # to test that it is ok
    deps = [
        ":py_library_3",
        ":pybind",
    ],
)

py_library(
    name = "py_library_3",
    srcs = [],
    # The only place where pybind_copy is provided, and it will be consumed by
    # pybind_aggregated only as a multi-level transitive dependency.
    deps = [":pybind_copy"],
)

py_library(
    name = "py_library_4",
    srcs = [],
    deps = [":pybind_cc_only"],
)

pywrap_library(
    name = "pybind_aggregated",
    common_lib_versions = {
        "framework": "2",
    },
    common_lib_def_files_or_filters = {
        "framework": "//pybind:framework.json",
        #        "framework": ":_libframework.so.2.def",
    },
    common_lib_filters = {
        "framework": select({
            "@bazel_tools//src/conditions:windows": [":fifth_library"],
            "//conditions:default": [":fifth_library"],
        }),
    },
    common_lib_linkopts = {
        "framework": select({
            "@bazel_tools//src/conditions:windows": [],
            "@bazel_tools//src/conditions:darwin": [],
            "//conditions:default": ["-z defs"],
        }),
    },
    common_lib_version_scripts = {
        "framework": select({
            "@bazel_tools//src/conditions:windows": None,
            "@bazel_tools//src/conditions:darwin": ":darwin_framework.lds",
            "//conditions:default": ":linux_framework.lds",
        }),
    },
    pywrap_count = 4,
    pywrap_lib_filter = ":third_library",
    starlark_only_pywrap_count = 1,
    visibility = ["//visibility:public"],
    deps = [
        ":py_library_1",
        ":py_library_2",
        ":py_library_3",
        ":py_library_4",
        ":pybind_with_starlark_only",
        "//pybind/sub_pybind:relative_import_lib",
    ],
)

pywrap_common_library(
    name = "common_pybind_aggregated_internal",
    dep = ":pybind_aggregated",
)

pywrap_common_library(
    name = "common_pybind_aggregated_framework",
    dep = ":pybind_aggregated",
    filter_name = "framework",
)

pywrap_binaries(
    name = "pybind_aggregated_binaries",
    dep = ":pybind_aggregated",
)

py_test(
    name = "pybind_py_test",
    srcs = ["pybind_py_test.py"],
    visibility = ["//:__pkg__"],
    deps = [
        ":pybind_aggregated",
        # not needed, since duplicated, but passed to check that duplication is
        # ok
        "py_library_1",
        "//pybind/sub_pybind:relative_import_lib",
    ],
#    legacy_create_init = False,
)

py_test(
    name = "pybind_with_starlark_only_py_test",
    srcs = ["pybind_with_starlark_only_py_test.py"],
    visibility = ["//:__pkg__"],
    deps = [
        ":pybind_aggregated",
        # not needed, since duplicated, but passed to check that duplication is
        # ok
        "py_library_1",
    ],
)

cc_test(
    name = "common_library_test",
    srcs = [
        "common_library_test.cc",
        "first_library.h",
        "second_library.h",
    ],
    visibility = ["//:__pkg__"],
    deps = [
        ":common_pybind_aggregated_framework",
        "@gtest//:gtest_main",
    ],
)

cc_test(
    name = "py_common_library_test",
    srcs = [
        "fifth_library.h",
        "first_library.h",
        "py_common_library_test.cc",
        "second_library.h",
    ],
    visibility = ["//:__pkg__"],
    deps = [
        ":common_pybind_aggregated_framework",
        ":common_pybind_aggregated_internal",
        "@gtest//:gtest_main",
    ],
)

# Pybind modules with wrapped PyInit_ function
pybind_extension(
    name = "pybind_wrapped",
    srcs = ["pybind.cc"],
    data = [":static_resource.txt"],
    deps = [
        ":fifth_library",
        ":first_library",
        ":second_library",
        ":third_library",
    ],
    wrap_py_init = True,
    local_defines = ["TARGET_NAME=pybind_wrapped"],
)

pybind_extension(
    name = "pybind_wrapped_copy",
    srcs = ["pybind_copy.cc"],
    deps = [
        ":first_library",
        ":second_library",
    ] + select({
        "//conditions:default": [":third_library"],
    }),
    wrap_py_init = True,
    local_defines = ["TARGET_NAME=pybind_wrapped_copy"],
)

pybind_extension(
    name = "pybind_wrapped_cc_only",
    visibility = ["//visibility:public"],
    deps = [
        ":fourth_library",
    ],
    wrap_py_init = True,
)

pywrap_library(
    name = "pybind_wrapped_aggregated",
    deps = [
        ":pybind_wrapped",
        ":pybind_wrapped_copy",
        ":pybind_wrapped_cc_only",
        "//pybind/sub_pybind:relative_wrapped_import_lib",
    ],
)

py_test(
    name = "pybind_wrapped_py_test",
    srcs = ["pybind_wrapped_py_test.py"],
    visibility = ["//:__pkg__"],
    deps = [
        ":pybind_wrapped_aggregated",
        "//pybind/sub_pybind:relative_wrapped_import_lib",
    ],
)

test_suite(
    name = "all",
    tests = [
        ":pybind_wrapped_py_test",
        ":pybind_py_test",
        ":pybind_with_starlark_only_py_test",
        ":common_library_test",
        ":py_common_library_test",
        ":regular_cc_test",
    ],
    visibility = ["//visibility:public"]
)
