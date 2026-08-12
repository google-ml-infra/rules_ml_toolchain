#include <gtest/gtest.h>
#include "utils.h"

// C++20 is recommended for modules feature check
#if !defined(__clang__) || !__has_feature(modules)
#error "Clang header modules are not enabled in Bazel!"
#endif

TEST(MathTest, AddsPositiveNumbers) {
    EXPECT_EQ(add(2, 2), 4);
}
