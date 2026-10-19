/* Copyright 2026 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/

#include <vector>

#include "fortran/tests/math_mod.h"
#include "gtest/gtest.h"

namespace {

TEST(FortranInteropTest, AddInts) {
  EXPECT_EQ(fortran_add_ints(20, 22), 42);
  EXPECT_EQ(fortran_add_ints(-10, 10), 0);
}

TEST(FortranInteropTest, DotProduct) {
  const std::vector<double> x = {1.0, 2.0, 3.0, 4.0};
  const std::vector<double> y = {5.0, 6.0, 7.0, 8.0};
  EXPECT_DOUBLE_EQ(
      fortran_dot_product(static_cast<int>(x.size()), x.data(), y.data()),
      70.0);
}

TEST(FortranInteropTest, Saxpy) {
  const std::vector<float> x = {1.0f, 2.0f, 3.0f};
  std::vector<float> y = {10.0f, 20.0f, 30.0f};
  fortran_saxpy(static_cast<int>(x.size()), 2.5f, x.data(), y.data());
  EXPECT_FLOAT_EQ(y[0], 12.5f);
  EXPECT_FLOAT_EQ(y[1], 25.0f);
  EXPECT_FLOAT_EQ(y[2], 37.5f);
}

}  // namespace
