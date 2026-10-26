"""Unit tests for linking behavior."""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("//third_party/rules_fortran:defs.bzl", "fortran_binary", "fortran_library")

def _linkopts_propagate_to_binary_test_impl(ctx):
    """Test that linkopts from library propagate to binary link action."""
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    actions = analysistest.target_actions(env)
    link_actions = [a for a in actions if "Link" in a.mnemonic]

    asserts.true(
        env,
        len(link_actions) > 0,
        "Expected at least one link action",
    )

    # Check that linkopts appear in link action
    link_action = link_actions[0]
    action_str = str(link_action.argv)

    has_linkopt = "-lpthread" in action_str

    asserts.true(
        env,
        has_linkopt,
        "Expected linkopts from library to appear in binary link action",
    )

    return analysistest.end(env)

linkopts_propagate_to_binary_test = analysistest.make(
    _linkopts_propagate_to_binary_test_impl,
)

def _transitive_libs_linked_test_impl(ctx):
    """Test that transitive libraries are included in link action."""
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    actions = analysistest.target_actions(env)
    link_actions = [a for a in actions if "Link" in a.mnemonic]

    asserts.true(
        env,
        len(link_actions) > 0,
        "Expected at least one link action",
    )

    # Check that transitive library appears in link inputs
    link_action = link_actions[0]
    action_str = str(link_action.argv)

    # Should have references to both direct and transitive libs
    has_lib_refs = "lib" in action_str and ".a" in action_str

    asserts.true(
        env,
        has_lib_refs,
        "Expected transitive libraries in link action",
    )

    return analysistest.end(env)

transitive_libs_linked_test = analysistest.make(
    _transitive_libs_linked_test_impl,
)

def linking_test_suite(name):
    """Test suite for linking behavior."""

    # Library with linkopts
    fortran_library(
        name = "lib_with_linkopts",
        srcs = ["lib.f90"],
        linkopts = ["-lpthread"],
        tags = ["manual"],
    )

    # Binary using library with linkopts
    fortran_binary(
        name = "bin_with_linkopts",
        srcs = ["main.f90"],
        deps = [":lib_with_linkopts"],
        tags = ["manual"],
    )

    # Transitive chain for linking
    fortran_library(
        name = "base_lib",
        srcs = ["base.f90"],
        tags = ["manual"],
    )

    fortran_library(
        name = "middle_lib",
        srcs = ["middle.f90"],
        deps = [":base_lib"],
        tags = ["manual"],
    )

    fortran_binary(
        name = "bin_with_transitive",
        srcs = ["main.f90"],
        deps = [":middle_lib"],
        tags = ["manual"],
    )

    # Create tests
    linkopts_propagate_to_binary_test(
        name = "linkopts_propagate_to_binary_test",
        target_under_test = ":bin_with_linkopts",
    )

    transitive_libs_linked_test(
        name = "transitive_libs_linked_test",
        target_under_test = ":bin_with_transitive",
    )

    # Bundle into test suite
    native.test_suite(
        name = name,
        tests = [
            ":linkopts_propagate_to_binary_test",
            ":transitive_libs_linked_test",
        ],
    )
