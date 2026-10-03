"""Unit tests for Fortran/C interoperability."""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("//third_party/rules_fortran:defs.bzl", "fortran_binary", "fortran_library")

def _fortran_library_compile_excludes_cc_link_flags_test_impl(ctx):
    """Test that fortran_library compile actions don't include cc_library link flags.

    Compile actions should only have compilation flags, not link flags from deps.
    """
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    # Get compile actions
    actions = analysistest.target_actions(env)
    compile_actions = [a for a in actions if a.mnemonic == "FortranCompile"]

    asserts.true(
        env,
        len(compile_actions) > 0,
        "Expected at least one FortranCompile action",
    )

    # Check that compile actions don't have -L flags (link-time flags)
    for action in compile_actions:
        for arg in action.argv:
            asserts.false(
                env,
                arg.startswith("-L"),
                "FortranCompile action should not have link flags like -L: {}".format(arg),
            )

    return analysistest.end(env)

fortran_library_compile_excludes_cc_link_flags_test = analysistest.make(
    _fortran_library_compile_excludes_cc_link_flags_test_impl,
)

def _fortran_binary_link_includes_cc_flags_test_impl(ctx):
    """Test that fortran_binary link actions include cc_library link flags.

    Binary link actions should have library files from cc_library deps.
    """
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    # Get all actions
    actions = analysistest.target_actions(env)

    # Find the link action (could be CppLink, FortranLink, or other)
    link_action = None
    for action in actions:
        # Link actions typically have "Link" in mnemonic
        if "Link" in action.mnemonic:
            link_action = action
            break

    asserts.true(
        env,
        link_action != None,
        "Expected to find a link action for fortran_binary",
    )

    if link_action:
        # Check that link action references the cc_library
        action_str = str(link_action.argv)
        has_cc_lib = "cc_dep" in action_str or "c_helper" in action_str

        asserts.true(
            env,
            has_cc_lib,
            "Expected fortran_binary link action to include cc_library dependency",
        )

    return analysistest.end(env)

fortran_binary_link_includes_cc_flags_test = analysistest.make(
    _fortran_binary_link_includes_cc_flags_test_impl,
)

def cc_interop_test_suite(name):
    """Test suite for Fortran/C interoperability."""

    # Create a simple C library
    cc_library(
        name = "cc_dep",
        srcs = ["c_helper.c"],
        hdrs = ["c_helper.h"],
        tags = ["manual"],
    )

    # Create fortran_library that depends on cc_library
    fortran_library(
        name = "fortran_with_cc_dep",
        srcs = ["fortran_module.f90"],
        deps = [":cc_dep"],
        tags = ["manual"],
    )

    # Create fortran_binary that depends on cc_library
    fortran_binary(
        name = "fortran_bin_with_cc_dep",
        srcs = ["fortran_main.f90"],
        deps = [":cc_dep"],
        tags = ["manual"],
    )

    # Create tests
    fortran_library_compile_excludes_cc_link_flags_test(
        name = "library_compile_excludes_cc_link_flags_test",
        target_under_test = ":fortran_with_cc_dep",
    )

    fortran_binary_link_includes_cc_flags_test(
        name = "binary_link_includes_cc_flags_test",
        target_under_test = ":fortran_bin_with_cc_dep",
    )

    # Bundle into test suite
    native.test_suite(
        name = name,
        tests = [
            ":library_compile_excludes_cc_link_flags_test",
            ":binary_link_includes_cc_flags_test",
        ],
    )
