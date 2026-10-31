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

#include <cudnn.h>
#include <cuda_runtime.h>
#include <iostream>
#include "gtest/gtest.h"

TEST(CudnnTest, ActivationForward) {
    int deviceCount = 0;
    cudaGetDeviceCount(&deviceCount);
    if (deviceCount == 0) {
        std::cout << "No CUDA devices found, skipping test." << std::endl;
        GTEST_SKIP();
    }

    cudnnHandle_t handle;
    EXPECT_EQ(cudnnCreate(&handle), CUDNN_STATUS_SUCCESS);

    cudnnTensorDescriptor_t xDesc;
    EXPECT_EQ(cudnnCreateTensorDescriptor(&xDesc), CUDNN_STATUS_SUCCESS);
    EXPECT_EQ(cudnnSetTensor4dDescriptor(xDesc, CUDNN_TENSOR_NCHW, CUDNN_DATA_FLOAT, 1, 1, 2, 2), CUDNN_STATUS_SUCCESS);

    cudnnActivationDescriptor_t actDesc;
    EXPECT_EQ(cudnnCreateActivationDescriptor(&actDesc), CUDNN_STATUS_SUCCESS);
    EXPECT_EQ(cudnnSetActivationDescriptor(actDesc, CUDNN_ACTIVATION_RELU, CUDNN_NOT_PROPAGATE_NAN, 0.0), CUDNN_STATUS_SUCCESS);

    float h_x[4] = {-1.0f, 0.5f, -0.1f, 2.0f};
    float h_y[4] = {0};
    
    float *d_x, *d_y;
    cudaMalloc(&d_x, sizeof(float)*4);
    cudaMalloc(&d_y, sizeof(float)*4);
    cudaMemcpy(d_x, h_x, sizeof(float)*4, cudaMemcpyHostToDevice);

    float alpha = 1.0f, beta = 0.0f;
    EXPECT_EQ(cudnnActivationForward(handle, actDesc, &alpha, xDesc, d_x, &beta, xDesc, d_y), CUDNN_STATUS_SUCCESS);

    cudaMemcpy(h_y, d_y, sizeof(float)*4, cudaMemcpyDeviceToHost);

    EXPECT_FLOAT_EQ(h_y[0], 0.0f);
    EXPECT_FLOAT_EQ(h_y[1], 0.5f);
    EXPECT_FLOAT_EQ(h_y[2], 0.0f);
    EXPECT_FLOAT_EQ(h_y[3], 2.0f);

    cudaFree(d_x);
    cudaFree(d_y);
    cudnnDestroyActivationDescriptor(actDesc);
    cudnnDestroyTensorDescriptor(xDesc);
    cudnnDestroy(handle);
}
