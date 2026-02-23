
#############################################
# Sanitizers
# TODO: Add one more test with feature '-asan'
cc_test(
    name = "asan_test",
    srcs = ["asan_test.cc"],
    deps = [
        "@gtest//:gtest_main",
    ],
    tags = [
        "notsan",
    ],
    #    copts = [
    #        "-fsanitize=address",
    #    ],
    #    linkopts = [
    #        "-fsanitize=address",
    #    ],
)

cc_test(
    name = "tsan_test",
    srcs = ["tsan_test.cc"],
    deps = [
        "@gtest//:gtest_main",
    ],
    tags = [
        "noasan",
    ],
#    copts = [
#        "-fsanitize=thread",
#    ],
#    linkopts = [
#        "-fsanitize=thread",
#    ],
)
