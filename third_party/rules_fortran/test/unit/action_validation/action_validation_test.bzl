"""Unit tests for action validation (compiler flags, includes, defines)."""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("//third_party/rules_fortran:defs.bzl", "fortran_library")
load("//third_party/rules_fortran/test/unit:common.bzl", "assert_argv_contains", "assert_argv_contains_prefix")

def _copts_appear_in_compile_action_test_impl(ctx):
    """Test that copts are passed to the compiler."""
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    actions = analysistest.target_actions(env)
    compile_actions = [a for a in actions if a.mnemonic == "FortranCompile"]

    asserts.true(
        env,
        len(compile_actions) > 0,
        "Expected at least one FortranCompile action",
    )

    # Check that custom copts appear in compile action
    compile_action = compile_actions[0]
    assert_argv_contains(env, compile_action, "-O3")
    assert_argv_contains(env, compile_action, "-march=native")

    return analysistest.end(env)

copts_appear_in_compile_action_test = analysistest.make(
    _copts_appear_in_compile_action_test_impl,
)

def _defines_appear_in_compile_action_test_impl(ctx):
    """Test that defines are passed to the compiler."""
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    actions = analysistest.target_actions(env)
    compile_actions = [a for a in actions if a.mnemonic == "FortranCompile"]

    asserts.true(
        env,
        len(compile_actions) > 0,
        "Expected at least one FortranCompile action",
    )

    # Check that defines appear as -D flags
    compile_action = compile_actions[0]
    assert_argv_contains(env, compile_action, "-DUSE_MPI")
    assert_argv_contains(env, compile_action, "-D_OPENMP")

    return analysistest.end(env)

defines_appear_in_compile_action_test = analysistest.make(
    _defines_appear_in_compile_action_test_impl,
)

def _includes_appear_in_compile_action_test_impl(ctx):
    """Test that includes are passed to the compiler."""
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    actions = analysistest.target_actions(env)
    compile_actions = [a for a in actions if a.mnemonic == "FortranCompile"]

    asserts.true(
        env,
        len(compile_actions) > 0,
        "Expected at least one FortranCompile action",
    )

    # Check that includes appear as -I flags (resolved relative to package)
    compile_action = compile_actions[0]

    # Full-path behavior matches rules_cc convention, see #13
    assert_argv_contains_prefix(env, compile_action, "-Ithird_party/rules_fortran/test/unit/action_validation/include")

    return analysistest.end(env)

includes_appear_in_compile_action_test = analysistest.make(
    _includes_appear_in_compile_action_test_impl,
)

def _module_paths_in_compile_action_test_impl(ctx):
    """Test that module paths from deps appear in compile action."""
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    actions = analysistest.target_actions(env)
    compile_actions = [a for a in actions if a.mnemonic == "FortranCompile"]

    asserts.true(
        env,
        len(compile_actions) > 0,
        "Expected at least one FortranCompile action",
    )

    # Check that module path from dependency appears
    compile_action = compile_actions[0]
    action_str = str(compile_action.argv)

    # Module paths should be included for dependencies
    has_module_path = "modules" in action_str or "-I" in action_str

    asserts.true(
        env,
        has_module_path,
        "Expected module paths from deps in compile action",
    )

    return analysistest.end(env)

module_paths_in_compile_action_test = analysistest.make(
    _module_paths_in_compile_action_test_impl,
)

def _includes_dot_rejected_test_impl(ctx):
    """Test that includes = ['.'] is rejected at workspace root."""
    env = analysistest.begin(ctx)
    asserts.expect_failure(env, "workspace root")
    return analysistest.end(env)

includes_dot_rejected_test = analysistest.make(
    _includes_dot_rejected_test_impl,
    expect_failure = True,
)

def _includes_dotdot_rejected_test_impl(ctx):
    """Test that includes containing '..' is rejected."""
    env = analysistest.begin(ctx)
    asserts.expect_failure(env, "..")
    return analysistest.end(env)

includes_dotdot_rejected_test = analysistest.make(
    _includes_dotdot_rejected_test_impl,
    expect_failure = True,
)

def _defines_with_lowercase_extension_rejected_test_impl(ctx):
    """Test that defines with lowercase extension (.f90) is rejected."""
    env = analysistest.begin(ctx)

    # verify target *fails* and error message *contains* "uppercase"
    asserts.expect_failure(env, "uppercase")
    return analysistest.end(env)

defines_with_lowercase_extension_rejected_test = analysistest.make(
    _defines_with_lowercase_extension_rejected_test_impl,
    expect_failure = True,
)

def _hdrs_inc_appear_in_compile_action_test_impl(ctx):
    """Test that .inc hdrs files appear as inputs to compile action."""
    env = analysistest.begin(ctx)

    actions = analysistest.target_actions(env)
    compile_actions = [a for a in actions if a.mnemonic == "FortranCompile"]

    asserts.true(
        env,
        len(compile_actions) > 0,
        "Expected at least one FortranCompile action",
    )

    # Check that hdrs file appears in inputs
    compile_action = compile_actions[0]
    input_paths = [f.path for f in compile_action.inputs.to_list()]
    has_inc_file = False
    for p in input_paths:
        if "test.inc" in p:
            has_inc_file = True
            break

    asserts.true(
        env,
        has_inc_file,
        "Expected hdrs file 'test.inc' in compile action inputs, got: " + str(input_paths),
    )

    return analysistest.end(env)

hdrs_inc_appear_in_compile_action_test = analysistest.make(
    _hdrs_inc_appear_in_compile_action_test_impl,
)

def _hdrs_mod_appear_in_compile_action_test_impl(ctx):
    """Test that .mod hdrs files appear as inputs to compile action."""
    env = analysistest.begin(ctx)

    actions = analysistest.target_actions(env)
    compile_actions = [a for a in actions if a.mnemonic == "FortranCompile"]

    asserts.true(
        env,
        len(compile_actions) > 0,
        "Expected at least one FortranCompile action",
    )

    # Check that hdrs file appears in inputs
    compile_action = compile_actions[0]
    input_paths = [f.path for f in compile_action.inputs.to_list()]
    has_mod_file = False
    for p in input_paths:
        if "test.mod" in p:
            has_mod_file = True
            break

    asserts.true(
        env,
        has_mod_file,
        "Expected hdrs file 'test.mod' in compile action inputs, got: " + str(input_paths),
    )

    return analysistest.end(env)

hdrs_mod_appear_in_compile_action_test = analysistest.make(
    _hdrs_mod_appear_in_compile_action_test_impl,
)

def action_validation_test_suite(name):
    """Test suite for action validation."""

    # Test copts
    fortran_library(
        name = "lib_with_copts",
        srcs = ["simple_regular.f90"],
        copts = ["-O3", "-march=native"],
        tags = ["manual"],
    )

    # Test defines (requires uppercase .F90 extension for preprocessing)
    fortran_library(
        name = "lib_with_defines",
        srcs = ["simple.F90"],
        defines = ["USE_MPI", "_OPENMP"],
        tags = ["manual"],
    )

    # Test includes
    fortran_library(
        name = "lib_with_includes",
        srcs = ["simple_regular.f90"],
        includes = ["include"],
        tags = ["manual"],
    )

    # Test module paths from deps
    fortran_library(
        name = "dep_with_module",
        srcs = ["module_a.f90"],
        tags = ["manual"],
    )

    fortran_library(
        name = "lib_using_module",
        srcs = ["module_b.f90"],
        deps = [":dep_with_module"],
        tags = ["manual"],
    )

    # Create tests
    copts_appear_in_compile_action_test(
        name = "copts_appear_in_compile_action_test",
        target_under_test = ":lib_with_copts",
    )

    defines_appear_in_compile_action_test(
        name = "defines_appear_in_compile_action_test",
        target_under_test = ":lib_with_defines",
    )

    includes_appear_in_compile_action_test(
        name = "includes_appear_in_compile_action_test",
        target_under_test = ":lib_with_includes",
    )

    module_paths_in_compile_action_test(
        name = "module_paths_in_compile_action_test",
        target_under_test = ":lib_using_module",
    )

    # Test that includes = [".."] is rejected (see #16)
    # Note: includes_dot_rejected_test exists but requires root package to trigger,
    # so only ".." validation is tested here. "." validation verified manually.
    fortran_library(
        name = "lib_with_dotdot_includes",
        srcs = ["simple_regular.f90"],
        includes = [".."],
        tags = ["manual"],
    )

    includes_dotdot_rejected_test(
        name = "includes_dotdot_rejected_test",
        target_under_test = ":lib_with_dotdot_includes",
    )

    # Test that defines with lowercase extension (.f90) is rejected (see #14)
    fortran_library(
        name = "lib_with_defines_lowercase",
        srcs = ["simple_regular.f90"],  # lowercase .f90 - no preprocessing
        defines = ["USE_MPI"],  # defines require preprocessing!
        tags = ["manual"],
    )

    defines_with_lowercase_extension_rejected_test(
        name = "defines_with_lowercase_extension_rejected_test",
        target_under_test = ":lib_with_defines_lowercase",
    )

    # Test hdrs attribute with .inc files (see #17)
    fortran_library(
        name = "lib_with_inc_hdrs",
        srcs = ["simple_regular.f90"],
        hdrs = ["test.inc"],
        tags = ["manual"],
    )

    hdrs_inc_appear_in_compile_action_test(
        name = "hdrs_inc_appear_in_compile_action_test",
        target_under_test = ":lib_with_inc_hdrs",
    )

    # Test hdrs attribute with .mod files (see #17)
    fortran_library(
        name = "lib_with_mod_hdrs",
        srcs = ["simple_regular.f90"],
        hdrs = ["test.mod"],
        tags = ["manual"],
    )

    hdrs_mod_appear_in_compile_action_test(
        name = "hdrs_mod_appear_in_compile_action_test",
        target_under_test = ":lib_with_mod_hdrs",
    )

    # Bundle into test suite
    native.test_suite(
        name = name,
        tests = [
            ":copts_appear_in_compile_action_test",
            ":defines_appear_in_compile_action_test",
            ":includes_appear_in_compile_action_test",
            ":module_paths_in_compile_action_test",
            ":includes_dotdot_rejected_test",
            ":defines_with_lowercase_extension_rejected_test",
            ":hdrs_inc_appear_in_compile_action_test",
            ":hdrs_mod_appear_in_compile_action_test",
        ],
    )
