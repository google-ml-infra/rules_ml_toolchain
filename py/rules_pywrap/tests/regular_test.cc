/* Copyright 2026 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
============================================================================== */

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

