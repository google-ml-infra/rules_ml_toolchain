"""Unit tests for edge cases."""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("@rules_cc//cc/common:cc_info.bzl", "CcInfo")
load("//third_party/rules_fortran:defs.bzl", "fortran_binary", "fortran_library")
load("//third_party/rules_fortran/private:providers.bzl", "FortranInfo")

def _empty_library_provides_providers_test_impl(ctx):
    """Test that library with no srcs still provides required providers."""
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    # Should provide FortranInfo even with no srcs
    asserts.true(
        env,
        FortranInfo in target,
        "Library with no srcs must provide FortranInfo",
    )

    # Should provide CcInfo even with no srcs
    asserts.true(
        env,
        CcInfo in target,
        "Library with no srcs must provide CcInfo",
    )

    return analysistest.end(env)

empty_library_provides_providers_test = analysistest.make(
    _empty_library_provides_providers_test_impl,
)

def _library_with_only_deps_test_impl(ctx):
    """Test aggregator library pattern (no srcs, only deps)."""
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    fortran_info = target[FortranInfo]
    transitive_libs = fortran_info.transitive_libraries.to_list()

    # Should propagate libs from dependencies
    asserts.true(
        env,
        len(transitive_libs) >= 1,
        "Aggregator library should propagate dependencies' libraries",
    )

    return analysistest.end(env)

library_with_only_deps_test = analysistest.make(
    _library_with_only_deps_test_impl,
)

def _binary_with_no_deps_test_impl(ctx):
    """Test that binary with no deps compiles and links correctly."""
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    actions = analysistest.target_actions(env)

    # Should have compile actions
    compile_actions = [a for a in actions if a.mnemonic == "FortranCompile"]
    asserts.true(
        env,
        len(compile_actions) > 0,
        "Binary with no deps should have compile actions",
    )

    # Should have link action
    link_actions = [a for a in actions if "Link" in a.mnemonic]
    asserts.true(
        env,
        len(link_actions) > 0,
        "Binary with no deps should have link action",
    )

    return analysistest.end(env)

binary_with_no_deps_test = analysistest.make(
    _binary_with_no_deps_test_impl,
)

def _single_source_library_test_impl(ctx):
    """Test library with single source file."""
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    fortran_info = target[FortranInfo]

    # Should have exactly one library
    transitive_libs = fortran_info.transitive_libraries.to_list()
    asserts.equals(
        env,
        len(transitive_libs),
        1,
        "Single source library should produce exactly one library",
    )

    return analysistest.end(env)

single_source_library_test = analysistest.make(
    _single_source_library_test_impl,
)

def edge_cases_test_suite(name):
    """Test suite for edge cases."""

    # Empty library (no srcs, no deps)
    fortran_library(
        name = "empty_lib",
        tags = ["manual"],
    )

    # Aggregator library (no srcs, only deps)
    fortran_library(
        name = "dep_a",
        srcs = ["dep_a.f90"],
        tags = ["manual"],
    )

    fortran_library(
        name = "aggregator",
        deps = [":dep_a"],
        tags = ["manual"],
    )

    # Binary with no deps
    fortran_binary(
        name = "standalone_bin",
        srcs = ["standalone.f90"],
        tags = ["manual"],
    )

    # Single source library
    fortran_library(
        name = "single_src_lib",
        srcs = ["single.f90"],
        tags = ["manual"],
    )

    # Create tests
    empty_library_provides_providers_test(
        name = "empty_library_provides_providers_test",
        target_under_test = ":empty_lib",
    )

    library_with_only_deps_test(
        name = "library_with_only_deps_test",
        target_under_test = ":aggregator",
    )

    binary_with_no_deps_test(
        name = "binary_with_no_deps_test",
        target_under_test = ":standalone_bin",
    )

    single_source_library_test(
        name = "single_source_library_test",
        target_under_test = ":single_src_lib",
    )

    # Bundle into test suite
    native.test_suite(
        name = name,
        tests = [
            ":empty_library_provides_providers_test",
            ":library_with_only_deps_test",
            ":binary_with_no_deps_test",
            ":single_source_library_test",
        ],
    )
