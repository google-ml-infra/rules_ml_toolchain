"""Unit tests for OpenMP compilation and linking."""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("@rules_cc//cc:cc_import.bzl", "cc_import")
load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("//third_party/rules_fortran:defs.bzl", "fortran_binary", "fortran_library", "fortran_test")
load("//third_party/rules_fortran/test/unit:common.bzl", "assert_argv_contains")

# --- helpers ---

def _get_compile_actions(env):
    return [a for a in analysistest.target_actions(env) if a.mnemonic == "FortranCompile"]

def _get_link_actions(env):
    return [a for a in analysistest.target_actions(env) if "Link" in a.mnemonic]

# --- test impls ---

def _fopenmp_compile_test_impl(ctx):
    """copts = ['-fopenmp'] appears in compile action."""
    env = analysistest.begin(ctx)
    actions = _get_compile_actions(env)
    asserts.true(env, len(actions) > 0, "expected FortranCompile action")
    assert_argv_contains(env, actions[0], "-fopenmp")
    return analysistest.end(env)

fopenmp_compile_test = analysistest.make(_fopenmp_compile_test_impl)

def _fopenmp_link_test_impl(ctx):
    """linkopts = ['-fopenmp'] appears in link action."""
    env = analysistest.begin(ctx)
    actions = _get_link_actions(env)
    asserts.true(env, len(actions) > 0, "expected link action")
    assert_argv_contains(env, actions[0], "-fopenmp")
    return analysistest.end(env)

fopenmp_link_test = analysistest.make(_fopenmp_link_test_impl)

def _fopenmp_compile_and_link_test_impl(ctx):
    """both compile and link actions get -fopenmp."""
    env = analysistest.begin(ctx)
    compile_actions = _get_compile_actions(env)
    link_actions = _get_link_actions(env)
    asserts.true(env, len(compile_actions) > 0, "expected FortranCompile action")
    asserts.true(env, len(link_actions) > 0, "expected link action")
    assert_argv_contains(env, compile_actions[0], "-fopenmp")
    assert_argv_contains(env, link_actions[0], "-fopenmp")
    return analysistest.end(env)

fopenmp_compile_and_link_test = analysistest.make(_fopenmp_compile_and_link_test_impl)

def _static_dep_in_link_inputs_test_impl(ctx):
    """cc_library (static) dep appears in link inputs."""
    env = analysistest.begin(ctx)
    actions = _get_link_actions(env)
    asserts.true(env, len(actions) > 0, "expected link action")

    input_paths = [f.path for f in actions[0].inputs.to_list()]
    has_static = False
    for p in input_paths:
        if p.endswith(".a") or p.endswith(".lib"):
            if "static_omp" in p:
                has_static = True
                break

    asserts.true(env, has_static, "expected static lib in link inputs: " + str(input_paths))
    return analysistest.end(env)

static_dep_in_link_inputs_test = analysistest.make(_static_dep_in_link_inputs_test_impl)

def _dynamic_dep_in_link_inputs_test_impl(ctx):
    """cc_import (shared) dep appears in link inputs."""
    env = analysistest.begin(ctx)
    actions = _get_link_actions(env)
    asserts.true(env, len(actions) > 0, "expected link action")

    input_paths = [f.path for f in actions[0].inputs.to_list()]
    has_dynamic = False
    for p in input_paths:
        if "fake_omp" in p and (p.endswith(".so") or p.endswith(".dll") or p.endswith(".dylib")):
            has_dynamic = True
            break

    asserts.true(env, has_dynamic, "expected shared lib in link inputs: " + str(input_paths))
    return analysistest.end(env)

dynamic_dep_in_link_inputs_test = analysistest.make(_dynamic_dep_in_link_inputs_test_impl)

def _cc_linkopts_propagate_test_impl(ctx):
    """cc_library linkopts (-lpthread) propagate to link action."""
    env = analysistest.begin(ctx)
    actions = _get_link_actions(env)
    asserts.true(env, len(actions) > 0, "expected link action")
    assert_argv_contains(env, actions[0], "-lpthread")
    return analysistest.end(env)

cc_linkopts_propagate_test = analysistest.make(_cc_linkopts_propagate_test_impl)

def _library_no_link_test_impl(ctx):
    """fortran_library with -fopenmp has no link action."""
    env = analysistest.begin(ctx)
    actions = _get_link_actions(env)
    asserts.equals(env, 0, len(actions), "fortran_library should not have link actions")
    return analysistest.end(env)

library_no_link_test = analysistest.make(_library_no_link_test_impl)

def _test_link_mnemonic_test_impl(ctx):
    """fortran_test produces FortranLinkTest mnemonic."""
    env = analysistest.begin(ctx)
    actions = analysistest.target_actions(env)
    mnemonics = [a.mnemonic for a in actions]
    asserts.true(env, "FortranLinkTest" in mnemonics, "expected FortranLinkTest mnemonic, got: " + str(mnemonics))
    return analysistest.end(env)

test_link_mnemonic_test = analysistest.make(_test_link_mnemonic_test_impl)

# --- suite ---

def omp_test_suite(name):
    """Test suite for OpenMP analysis tests."""

    # cc deps
    cc_library(
        name = "static_omp",
        srcs = ["helper.c"],
        tags = ["manual"],
    )

    cc_library(
        name = "cc_with_linkopts",
        srcs = ["helper.c"],
        linkopts = ["-lpthread"],
        tags = ["manual"],
    )

    cc_import(
        name = "shared_omp",
        shared_library = "fake_omp.so",
        tags = ["manual"],
    )

    # targets under test
    fortran_binary(
        name = "bin_fopenmp_compile",
        srcs = ["simple.f90"],
        copts = ["-fopenmp"],
        tags = ["manual"],
    )

    fortran_binary(
        name = "bin_fopenmp_link",
        srcs = ["simple.f90"],
        linkopts = ["-fopenmp"],
        tags = ["manual"],
    )

    fortran_binary(
        name = "bin_fopenmp_both",
        srcs = ["simple.f90"],
        copts = ["-fopenmp"],
        linkopts = ["-fopenmp"],
        tags = ["manual"],
    )

    fortran_binary(
        name = "bin_static_dep",
        srcs = ["simple.f90"],
        copts = ["-fopenmp"],
        deps = [":static_omp"],
        tags = ["manual"],
    )

    fortran_binary(
        name = "bin_dynamic_dep",
        srcs = ["simple.f90"],
        copts = ["-fopenmp"],
        deps = [":shared_omp"],
        tags = ["manual"],
    )

    fortran_binary(
        name = "bin_cc_linkopts",
        srcs = ["simple.f90"],
        deps = [":cc_with_linkopts"],
        tags = ["manual"],
    )

    fortran_library(
        name = "lib_fopenmp",
        srcs = ["simple.f90"],
        copts = ["-fopenmp"],
        tags = ["manual"],
    )

    fortran_test(
        name = "test_fopenmp",
        srcs = ["simple.f90"],
        copts = ["-fopenmp"],
        linkopts = ["-fopenmp"],
        tags = ["manual"],
    )

    # analysis tests
    fopenmp_compile_test(
        name = "fopenmp_compile_test",
        target_under_test = ":bin_fopenmp_compile",
    )

    fopenmp_link_test(
        name = "fopenmp_link_test",
        target_under_test = ":bin_fopenmp_link",
    )

    fopenmp_compile_and_link_test(
        name = "fopenmp_compile_and_link_test",
        target_under_test = ":bin_fopenmp_both",
    )

    static_dep_in_link_inputs_test(
        name = "static_dep_in_link_inputs_test",
        target_under_test = ":bin_static_dep",
    )

    dynamic_dep_in_link_inputs_test(
        name = "dynamic_dep_in_link_inputs_test",
        target_under_test = ":bin_dynamic_dep",
    )

    cc_linkopts_propagate_test(
        name = "cc_linkopts_propagate_test",
        target_under_test = ":bin_cc_linkopts",
    )

    library_no_link_test(
        name = "library_no_link_test",
        target_under_test = ":lib_fopenmp",
    )

    test_link_mnemonic_test(
        name = "test_link_mnemonic_test",
        target_under_test = ":test_fopenmp",
    )

    native.test_suite(
        name = name,
        tests = [
            ":fopenmp_compile_test",
            ":fopenmp_link_test",
            ":fopenmp_compile_and_link_test",
            ":static_dep_in_link_inputs_test",
            ":dynamic_dep_in_link_inputs_test",
            ":cc_linkopts_propagate_test",
            ":library_no_link_test",
            ":test_link_mnemonic_test",
        ],
    )
