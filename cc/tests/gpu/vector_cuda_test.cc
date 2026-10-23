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

#include "vector_cuda.cu.h"
#include "gtest/gtest.h"

TEST(VectorCudaTest, VectorCudaTest) {
    EXPECT_EQ(90, VectorGenerateAndSum(10));
}

TEST(VectorCudaTest, GatherBFloat16GradTest) {
    constexpr int kNumSlices = 2;
    constexpr int kSliceSize = 6;
    const float grad[kSliceSize] = {
        -0.96484375f, -1.4921875f, -0.08496094f,
        -1.0390625f,  0.33007812f, -0.13476562f,
    };
    float params_grad[kNumSlices * kSliceSize] = {0.0f};

    GatherBFloat16Grad(grad, /*index=*/1, params_grad, kNumSlices, kSliceSize);

    for (int i = 0; i < kSliceSize; ++i) {
        EXPECT_FLOAT_EQ(0.0f, params_grad[i]);
        EXPECT_FLOAT_EQ(grad[i], params_grad[kSliceSize + i]);
    }
}

