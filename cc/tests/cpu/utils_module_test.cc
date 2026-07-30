// math_test.cc
#include <gtest/gtest.h>
#include <string>
#include "absl/container/flat_hash_map.h"

import UtilsModule;

TEST(UtilsModuleTest, AddsTwoNumbers) {
    EXPECT_EQ(add(2, 3), 5);
    EXPECT_EQ(add(-1, 1), 0);
}

TEST(UtilsModuleTest, ConcatenatesStrings) {
    std::string result = concat_strings("Hello, ", "Bazel!");
    EXPECT_EQ(result, "Hello, Bazel!");
}

TEST(UtilsModuleTest, SplitString) {
    std::vector<std::string> v = split_string("Hello,C++ Modules,StrSplit,and,StrSplit,methods", ',');
    EXPECT_EQ(v.at(1), "C++ Modules");
}

TEST(UtilsModuleTest, SortNums) {
    std::vector<int> nums = {20, 13, 50, 16, 77, 8, 99, 10};
    sort(nums);
    EXPECT_EQ(nums.at(0), 8);
}

TEST(UtilsModuleTest, HashMapAt) {
    absl::flat_hash_map<int, std::string> map = {{1, "Hello"}, {2, "Abseil flat_hash_map"}, };
    EXPECT_EQ(value_at(map, 2), "Abseil flat_hash_map");
}
