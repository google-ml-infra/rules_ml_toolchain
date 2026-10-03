"""Unit tests for Fortran module file propagation."""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("//third_party/rules_fortran:defs.bzl", "fortran_library")
load("//third_party/rules_fortran/private:providers.bzl", "FortranInfo")

def _transitive_modules_excludes_cc_outputs_test_impl(ctx):
    """Test that FortranInfo.transitive_modules only contains Fortran module directories.

    When a fortran_library depends on cc_library, the transitive_modules
    should not include any C/C++ outputs, only module directories.
    """
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    # Check FortranInfo exists
    asserts.true(
        env,
        FortranInfo in target,
        "fortran_library must provide FortranInfo",
    )

    fortran_info = target[FortranInfo]
    transitive_modules = fortran_info.transitive_modules.to_list()

    # All transitive modules should be directories (not .o or .a files)
    for module_dir in transitive_modules:
        asserts.false(
            env,
            module_dir.path.endswith(".o") or module_dir.path.endswith(".a"),
            "transitive_modules should not contain object/archive files: {}".format(module_dir.path),
        )

    return analysistest.end(env)

transitive_modules_excludes_cc_outputs_test = analysistest.make(
    _transitive_modules_excludes_cc_outputs_test_impl,
)

def _module_propagation_test_impl(ctx):
    """Test that module directories propagate through dependency chain.

    If lib_c depends on lib_b which depends on lib_a, lib_c should have
    transitive access to all module directories from lib_a and lib_b.
    """
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    fortran_info = target[FortranInfo]
    transitive_modules = fortran_info.transitive_modules.to_list()

    # Should have module directories from all dependencies (lib_a, lib_b, lib_c)
    asserts.true(
        env,
        len(transitive_modules) >= 3,
        "Expected module directories from all deps in chain (found {})".format(len(transitive_modules)),
    )

    return analysistest.end(env)

modules_propagate_transitively_test = analysistest.make(
    _module_propagation_test_impl,
)

def module_propagation_test_suite(name):
    """Test suite for Fortran module propagation."""

    # Create C library dep
    cc_library(
        name = "cc_dep",
        srcs = ["dummy.c"],
        tags = ["manual"],
    )

    # Create fortran library chain: lib_a -> lib_b -> lib_c
    fortran_library(
        name = "lib_a",
        srcs = ["module_a.f90"],
        tags = ["manual"],
    )

    fortran_library(
        name = "lib_b",
        srcs = ["module_b.f90"],
        deps = [":lib_a"],
        tags = ["manual"],
    )

    fortran_library(
        name = "lib_c",
        srcs = ["module_c.f90"],
        deps = [":lib_b", ":cc_dep"],
        tags = ["manual"],
    )

    # Create tests
    transitive_modules_excludes_cc_outputs_test(
        name = "transitive_modules_excludes_cc_outputs_test",
        target_under_test = ":lib_c",
    )

    modules_propagate_transitively_test(
        name = "modules_propagate_transitively_test",
        target_under_test = ":lib_c",
    )

    # Bundle into test suite
    native.test_suite(
        name = name,
        tests = [
            ":transitive_modules_excludes_cc_outputs_test",
            ":modules_propagate_transitively_test",
        ],
    )
