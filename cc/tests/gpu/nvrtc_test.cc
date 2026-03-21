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

#include <nvrtc.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include <iostream>
#include <vector>
#include "gtest/gtest.h"

#define NVRTC_SAFE_CALL(x)                                \
  do {                                                    \
    nvrtcResult result = x;                               \
    if (result != NVRTC_SUCCESS) {                        \
      FAIL() << "NVRTC Error: " << nvrtcGetErrorString(result); \
    }                                                     \
  } while(0)

#define CUDA_SAFE_CALL(x)                                 \
  do {                                                    \
    CUresult result = x;                                  \
    if (result != CUDA_SUCCESS) {                         \
      const char *msg;                                    \
      cuGetErrorString(result, &msg);                     \
      FAIL() << "CUDA Error: " << msg;                    \
    }                                                     \
  } while(0)

TEST(NvrtcTest, CompileAndRun) {
    int deviceCount = 0;
    cudaGetDeviceCount(&deviceCount);
    if (deviceCount == 0) {
        std::cout << "No CUDA devices found, skipping test." << std::endl;
        GTEST_SKIP();
    }

    const char *saxpy_src = R"(
    extern "C" __global__
    void saxpy(float a, float *x, float *y, float *out, size_t n) {
      size_t tid = blockIdx.x * blockDim.x + threadIdx.x;
      if (tid < n) {
        out[tid] = a * x[tid] + y[tid];
      }
    }
    )";

    nvrtcProgram prog;
    NVRTC_SAFE_CALL(nvrtcCreateProgram(&prog, saxpy_src, "saxpy.cu", 0, NULL, NULL));
    
    const char *opts[] = {"--gpu-architecture=compute_50"};
    nvrtcResult compileResult = nvrtcCompileProgram(prog, 1, opts);
    
    size_t logSize;
    NVRTC_SAFE_CALL(nvrtcGetProgramLogSize(prog, &logSize));
    if (logSize > 1) {
        std::vector<char> log(logSize);
        NVRTC_SAFE_CALL(nvrtcGetProgramLog(prog, log.data()));
        std::cout << "Compile log: " << log.data() << std::endl;
    }
    EXPECT_EQ(compileResult, NVRTC_SUCCESS);

    size_t ptxSize;
    NVRTC_SAFE_CALL(nvrtcGetPTXSize(prog, &ptxSize));
    std::vector<char> ptx(ptxSize);
    NVRTC_SAFE_CALL(nvrtcGetPTX(prog, ptx.data()));
    NVRTC_SAFE_CALL(nvrtcDestroyProgram(&prog));
    
    EXPECT_GT(ptxSize, 0);

    CUDA_SAFE_CALL(cuInit(0));
    CUdevice cuDevice;
    CUDA_SAFE_CALL(cuDeviceGet(&cuDevice, 0));
    CUcontext context;
    CUDA_SAFE_CALL(cuCtxCreate(&context, nullptr, 0, cuDevice));
    
    CUmodule module;
    CUDA_SAFE_CALL(cuModuleLoadDataEx(&module, ptx.data(), 0, 0, 0));
    
    CUfunction kernel;
    CUDA_SAFE_CALL(cuModuleGetFunction(&kernel, module, "saxpy"));
    
    size_t n = 4;
    float h_x[] = {1.0f, 2.0f, 3.0f, 4.0f};
    float h_y[] = {10.0f, 20.0f, 30.0f, 40.0f};
    float h_out[4] = {0};
    
    CUdeviceptr d_x, d_y, d_out;
    CUDA_SAFE_CALL(cuMemAlloc(&d_x, n * sizeof(float)));
    CUDA_SAFE_CALL(cuMemAlloc(&d_y, n * sizeof(float)));
    CUDA_SAFE_CALL(cuMemAlloc(&d_out, n * sizeof(float)));
    
    CUDA_SAFE_CALL(cuMemcpyHtoD(d_x, h_x, n * sizeof(float)));
    CUDA_SAFE_CALL(cuMemcpyHtoD(d_y, h_y, n * sizeof(float)));
    
    float a = 2.0f;
    void *args[] = {&a, &d_x, &d_y, &d_out, &n};
    
    // Launch kernel with proper parameters
    CUDA_SAFE_CALL(cuLaunchKernel(kernel, 1, 1, 1, n, 1, 1, 0, NULL, args, NULL));
    CUDA_SAFE_CALL(cuCtxSynchronize());
    
    CUDA_SAFE_CALL(cuMemcpyDtoH(h_out, d_out, n * sizeof(float)));
    
    EXPECT_FLOAT_EQ(h_out[0], 12.0f);
    EXPECT_FLOAT_EQ(h_out[1], 24.0f);
    EXPECT_FLOAT_EQ(h_out[2], 36.0f);
    EXPECT_FLOAT_EQ(h_out[3], 48.0f);
    
    cuMemFree(d_x);
    cuMemFree(d_y);
    cuMemFree(d_out);
    cuModuleUnload(module);
    cuCtxDestroy(context);
}
