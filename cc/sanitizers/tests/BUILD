
#############################################
# Sanitizers
# TODO: Add one more test with feature '-asan'
cc_test(
    name = "sanitizers_test",
    srcs = ["sanitizers_test.cc"],
    deps = [
        "@gtest//:gtest_main",
    ],
    #    copts = [
    #        "-fsanitize=address",
    #    ],
    #    linkopts = [
    #        "-fsanitize=address",
    #    ],
)

#############################################
# Tests Suite
test_suite(
    name = "all",
    tests = [
        ":sanitizers_test",
    ],
)