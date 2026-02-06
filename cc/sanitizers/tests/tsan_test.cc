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
#include <vector>
#include <thread>

#include "gtest/gtest.h"

// This function purposefully causes a data race
void trigger_tsan_race() {
    int counter = 0;

    std::thread t1([&]() { counter++; });
    std::thread t2([&]() { counter++; });

    t1.join();
    t2.join();
}

TEST(SanitizersTest, SanitizersTest) {
    EXPECT_DEATH({
       trigger_tsan_race();
    }, "ThreadSanitizer: data race");
}
