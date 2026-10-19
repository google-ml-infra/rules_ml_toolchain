"""Common test helpers for unit tests."""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")

def assert_argv_contains(env, action, flag):
    """Assert that action argv contains the given flag."""
    asserts.true(
        env,
        flag in action.argv,
        "Expected {args} to contain {flag}".format(args = action.argv, flag = flag),
    )

def assert_argv_contains_not(env, action, flag):
    """Assert that action argv does not contain the given flag."""
    asserts.true(
        env,
        flag not in action.argv,
        "Expected {args} to not contain {flag}".format(args = action.argv, flag = flag),
    )

def assert_argv_contains_prefix(env, action, prefix):
    """Assert that action argv contains a flag with the given prefix."""
    for found_flag in action.argv:
        if found_flag.startswith(prefix):
            return
    unittest.fail(
        env,
        "Expected an arg with prefix '{prefix}' in {args}".format(
            prefix = prefix,
            args = action.argv,
        ),
    )

def assert_argv_contains_prefix_not(env, action, prefix):
    """Assert that action argv does not contain any flag with the given prefix."""
    for found_flag in action.argv:
        if found_flag.startswith(prefix):
            unittest.fail(
                env,
                "Expected an arg with prefix '{prefix}' to not appear in {args}".format(
                    prefix = prefix,
                    args = action.argv,
                ),
            )

def assert_action_mnemonic(env, action, mnemonic):
    """Assert that action has the expected mnemonic."""
    if not action.mnemonic == mnemonic:
        unittest.fail(
            env,
            "Expected the action to have the mnemonic '{expected}', but got '{actual}'".format(
                expected = mnemonic,
                actual = action.mnemonic,
            ),
        )

def assert_list_contains_adjacent_elements(env, list_under_test, adjacent_elements):
    """Assert that list contains the given adjacent elements in order.

    Args:
        env: env from analysistest.begin(ctx).
        list_under_test: list supposed to contain adjacent elements.
        adjacent_elements: list of elements to be found adjacent in list_under_test.
    """
    for idx in range(len(list_under_test)):
        if list_under_test[idx] == adjacent_elements[0]:
            if list_under_test[idx:idx + len(adjacent_elements)] == adjacent_elements:
                return
    unittest.fail(
        env,
        "Expected to find adjacent elements {elements} in {list}".format(
            elements = adjacent_elements,
            list = list_under_test,
        ),
    )
