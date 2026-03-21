#include "regular.h"

#include <iostream>

#include "regular_copy.h"
#include "gtest/gtest.h"


TEST(RegularTest, RegularTest) {
  std::cout << "1: regular_first_func" << std::endl;
  EXPECT_EQ(regular_first_func(1), 2);
  std::cout << "2: regular_second_func" << std::endl;
  EXPECT_EQ(regular_second_func(1), 2);
  std::cout << "3: regular_copy_first_func" << std::endl;
  EXPECT_EQ(regular_copy_first_func(1), 4);
  std::cout << "4: regular_copy_second_func" << std::endl;
  EXPECT_EQ(regular_copy_second_func(1), 4);
}

