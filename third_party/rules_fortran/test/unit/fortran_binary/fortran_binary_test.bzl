"""Unit tests for fortran_binary rule."""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("@rules_cc//cc/common:cc_info.bzl", "CcInfo")
load("//third_party/rules_fortran:defs.bzl", "fortran_binary", "fortran_library")

def _fortran_binary_does_not_provide_ccinfo_test_impl(ctx):
    """Test that fortran_binary does not provide CcInfo.

    Binaries are final artifacts and should not expose CcInfo for linking.
    """
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    # Assert CcInfo is NOT provided
    asserts.false(
        env,
        CcInfo in target,
        "fortran_binary must NOT provide CcInfo (binaries are final artifacts)",
    )

    return analysistest.end(env)

fortran_binary_does_not_provide_ccinfo_test = analysistest.make(
    _fortran_binary_does_not_provide_ccinfo_test_impl,
)

def _fortran_binary_with_deps_does_not_provide_ccinfo_test_impl(ctx):
    """Test that fortran_binary with deps does not provide CcInfo."""
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    asserts.false(
        env,
        CcInfo in target,
        "fortran_binary must NOT provide CcInfo even with fortran_library deps",
    )

    return analysistest.end(env)

fortran_binary_with_deps_does_not_provide_ccinfo_test = analysistest.make(
    _fortran_binary_with_deps_does_not_provide_ccinfo_test_impl,
)

def fortran_binary_test_suite(name):
    """Test suite for fortran_binary rule."""

    # Test fixture: simple binary
    fortran_binary(
        name = "simple_bin",
        srcs = ["simple_main.f90"],
        tags = ["manual"],
    )

    # Test fixture: binary with library dep
    fortran_library(
        name = "dep_lib",
        srcs = ["simple_lib.f90"],
        tags = ["manual"],
    )

    fortran_binary(
        name = "bin_with_deps",
        srcs = ["simple_main.f90"],
        deps = [":dep_lib"],
        tags = ["manual"],
    )

    # Create tests
    fortran_binary_does_not_provide_ccinfo_test(
        name = "binary_does_not_provide_ccinfo_test",
        target_under_test = ":simple_bin",
    )

    fortran_binary_with_deps_does_not_provide_ccinfo_test(
        name = "binary_with_deps_does_not_provide_ccinfo_test",
        target_under_test = ":bin_with_deps",
    )

    # Bundle into test suite
    native.test_suite(
        name = name,
        tests = [
            ":binary_does_not_provide_ccinfo_test",
            ":binary_with_deps_does_not_provide_ccinfo_test",
        ],
    )
