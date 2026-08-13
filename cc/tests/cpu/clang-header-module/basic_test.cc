#include <gtest/gtest.h>
#include "utils.h"

// Verify Bazel use_header_modules feature is activated
#ifndef BAZEL_CLANG_USE_HEADER_MODULES_ACTIVE
#error "Bazel failed to apply the 'use_header_modules' feature to this target!"
#endif

// Verify Clang acknowledges the module engine is on
#if !defined(__clang__) || !__has_feature(modules)
#error "Clang header modules are not enabled in Bazel!"
#endif

TEST(MathTest, AddsPositiveNumbers) {
    EXPECT_EQ(add(2, 2), 4);
}
