// math_test.cc
#include <gtest/gtest.h>
#include <string>

import UtilsModule;

TEST(UtilsModuleTest, AddsTwoNumbers) {
    EXPECT_EQ(add(2, 3), 5);
    EXPECT_EQ(add(-1, 1), 0);
}

TEST(UtilsModuleTest, ConcatenatesStrings) {
    std::string result = concat_strings("Hello, ", "Bazel!");
    EXPECT_EQ(result, "Hello, Bazel!");
}