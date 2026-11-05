"""Unit tests for fortran_library rule."""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("@rules_cc//cc/common:cc_info.bzl", "CcInfo")
load("//third_party/rules_fortran:defs.bzl", "fortran_library")
load("//third_party/rules_fortran/private:providers.bzl", "FortranInfo")

def _fortran_library_provides_ccinfo_test_impl(ctx):
    """Test that fortran_library provides CcInfo for C interop."""
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    # Assert CcInfo is provided
    asserts.true(
        env,
        CcInfo in target,
        "fortran_library must provide CcInfo for C interop",
    )

    # Assert linking context exists
    if CcInfo in target:
        cc_info = target[CcInfo]
        linker_inputs = cc_info.linking_context.linker_inputs.to_list()
        asserts.true(
            env,
            len(linker_inputs) > 0,
            "fortran_library must provide linker inputs",
        )

    return analysistest.end(env)

fortran_library_provides_ccinfo_test = analysistest.make(
    _fortran_library_provides_ccinfo_test_impl,
)

def _fortran_library_provides_fortran_info_test_impl(ctx):
    """Test that fortran_library provides FortranInfo."""
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    # Check FortranInfo provider exists
    asserts.true(
        env,
        FortranInfo in target,
        "fortran_library must provide FortranInfo",
    )

    return analysistest.end(env)

fortran_library_provides_fortran_info_test = analysistest.make(
    _fortran_library_provides_fortran_info_test_impl,
)

def _ccinfo_has_static_library_test_impl(ctx):
    """Test that CcInfo.linking_context contains a static library."""
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    cc_info = target[CcInfo]
    linker_inputs = cc_info.linking_context.linker_inputs.to_list()

    asserts.true(
        env,
        len(linker_inputs) > 0,
        "fortran_library CcInfo must have linker_inputs",
    )

    # Check that at least one library exists
    libraries = linker_inputs[0].libraries
    asserts.true(
        env,
        len(libraries) > 0,
        "fortran_library CcInfo linker_inputs must have libraries",
    )

    # Check that library has static_library set
    lib = libraries[0]
    asserts.true(
        env,
        lib.static_library != None,
        "fortran_library must produce static_library in library_to_link",
    )

    return analysistest.end(env)

ccinfo_has_static_library_test = analysistest.make(
    _ccinfo_has_static_library_test_impl,
)

def _ccinfo_alwayslink_is_false_test_impl(ctx):
    """Test that library_to_link has alwayslink=False by default."""
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    cc_info = target[CcInfo]
    linker_inputs = cc_info.linking_context.linker_inputs.to_list()

    if len(linker_inputs) > 0 and len(linker_inputs[0].libraries) > 0:
        lib = linker_inputs[0].libraries[0]
        asserts.false(
            env,
            lib.alwayslink,
            "fortran_library should have alwayslink=False by default",
        )

    return analysistest.end(env)

ccinfo_alwayslink_is_false_test = analysistest.make(
    _ccinfo_alwayslink_is_false_test_impl,
)

def fortran_library_test_suite(name):
    """Test suite for fortran_library rule."""

    # Create test fixture
    fortran_library(
        name = "simple_lib",
        srcs = ["simple.f90"],
        tags = ["manual"],  # Don't build unless explicitly requested
    )

    # Create tests
    fortran_library_provides_ccinfo_test(
        name = "provides_ccinfo_test",
        target_under_test = ":simple_lib",
    )

    fortran_library_provides_fortran_info_test(
        name = "provides_fortran_info_test",
        target_under_test = ":simple_lib",
    )

    ccinfo_has_static_library_test(
        name = "ccinfo_has_static_library_test",
        target_under_test = ":simple_lib",
    )

    ccinfo_alwayslink_is_false_test(
        name = "ccinfo_alwayslink_is_false_test",
        target_under_test = ":simple_lib",
    )

    # Bundle into test suite
    native.test_suite(
        name = name,
        tests = [
            ":provides_ccinfo_test",
            ":provides_fortran_info_test",
            ":ccinfo_has_static_library_test",
            ":ccinfo_alwayslink_is_false_test",
        ],
    )
