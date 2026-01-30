/* Copyright 2025 Google LLC

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

#include <iostream>
#include <cassert>
#include <string>
#include <vector>

#include "gtest/gtest.h"

int cause_asan_error() {
    std::vector<int> data(10);

    std::cout << "Attempting to write to element 10 (valid range 0-9)..." << std::endl;

    // ERROR: Access element at index 10.
    std::cout << "Trying to extract 10th element " << data[10] << std::endl;
    return 0;
}

TEST(SanitizersTest, SanitizersTest) {
    EXPECT_EQ(0, cause_asan_error());
}
