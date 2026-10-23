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
#if __has_include(<bit>)
#include <bit>
#endif
#include <stdint.h>
#include <stdio.h>

#if defined(__NVCC__)
// Promote cross-execution-space call warnings to errors so build-only CI also
// catches if std::bit_cast<half> is treated as a __host__-only function.
#pragma nv_diag_error 20011
#pragma nv_diag_error 20014
#endif

__global__ void VectorAdd(const int *a, const int *b, int *c, int n) {
  int i = threadIdx.x;

  if(i < n) {
    c[i] += a[i] + b[i];
  }
}

int VectorGenerateAndSum(int size) {
  int *a, *b, *c;

  cudaMallocManaged(&a, sizeof(int) * size);
  cudaMallocManaged(&b, sizeof(int) * size);
  cudaMallocManaged(&c, sizeof(int) * size);

  for(int i = 1; i <= size; ++i) {
    a[i] = i;
    b[i] = i;
    c[i] = 0;
  }

  int sum = 0;
  VectorAdd<<<1, size>>>(a, b, c, size);
  cudaDeviceSynchronize();
  for(int i = 0; i < size; ++i) {
    printf("c[%d] = %d\n", i, c[i]);
    sum += c[i];
  }

  cudaFree(a);
  cudaFree(b);
  cudaFree(c);

  return sum;
}

namespace {

struct __half_raw {
  uint16_t x;
};

struct half_base : public __half_raw {
  __host__ __device__ half_base() {}
  __host__ __device__ half_base(const __half_raw &h) : __half_raw(h) {}
};

// Matches Eigen::half when EIGEN_HAS_GPU_FP16 is enabled: trivially copyable,
// but its default constructor is not constexpr (so it is not a literal type in
// C++20).
struct half : public half_base {
  __host__ __device__ half() {}
  __host__ __device__ half(const __half_raw &h) : half_base(h) {}
};

struct bfloat16 {
  uint16_t value;
  __host__ __device__ constexpr bfloat16() : value(0) {}
  __host__ __device__ constexpr explicit bfloat16(uint16_t v) : value(v) {}
};

// Matches Eigen::numext::bit_cast in Eigen/src/Core/NumTraits.h.
#if defined(__cpp_lib_bit_cast) && __cpp_lib_bit_cast >= 201806L
template <typename Tgt, typename Src>
__host__ __device__ constexpr Tgt bit_cast(const Src &src) {
  return std::bit_cast<Tgt>(src);
}
#else
template <typename Tgt, typename Src>
__host__ __device__ constexpr Tgt bit_cast(const Src &src) {
  return __builtin_bit_cast(Tgt, src);
}
#endif

__host__ __device__ inline bfloat16 FloatToBFloat16(float f) {
  uint32_t bits = bit_cast<uint32_t>(f);
  return bfloat16(static_cast<uint16_t>(bits >> 16));
}

__host__ __device__ inline float BFloat16ToFloat(bfloat16 bf) {
  uint32_t bits = static_cast<uint32_t>(bf.value) << 16;
  return bit_cast<float>(bits);
}

__host__ __device__ inline bfloat16 operator+(bfloat16 a, bfloat16 b) {
  return FloatToBFloat16(BFloat16ToFloat(a) + BFloat16ToFloat(b));
}

// Matches TensorFlow's GpuAtomicCasHelper / GpuAtomicAdd for Eigen::bfloat16
// in tensorflow/core/util/gpu_device_functions.h.
namespace detail {
template <typename T, typename F>
__device__ T GpuAtomicCasHelper(T *ptr, F accumulate) {
  T old = *ptr;
  T assumed;
  do {
    assumed = old;
    old = atomicCAS(ptr, assumed, accumulate(assumed));
  } while (assumed != old);
  return old;
}

template <typename F>
__device__ half GpuAtomicCasHelper(half *ptr, F accumulate) {
  uintptr_t intptr = reinterpret_cast<uintptr_t>(ptr);
  uint32_t shift = (intptr & 0x2) * 8U;
  uint32_t mask = 0xFFFF0000U >> shift;

  uint32_t *address = reinterpret_cast<uint32_t *>(intptr & ~0x3);
  uint32_t result =
      GpuAtomicCasHelper(address, [accumulate, shift, mask](uint32_t arg) {
        uint16_t high = static_cast<uint16_t>(arg >> shift);
        half acc = accumulate(bit_cast<half>(high));
        return (static_cast<uint32_t>(bit_cast<uint16_t>(acc)) << shift) |
               (arg & mask);
      });
  return bit_cast<half>(static_cast<uint16_t>(result >> shift));
}

template <typename F>
__device__ bfloat16 GpuAtomicCasHelper(bfloat16 *ptr, F accumulate) {
  half ret = detail::GpuAtomicCasHelper(
      reinterpret_cast<half *>(ptr), [accumulate](half a) {
        bfloat16 acc = accumulate(bit_cast<bfloat16>(a));
        return bit_cast<half>(acc);
      });
  return bit_cast<bfloat16>(ret);
}
}  // namespace detail

__device__ inline bfloat16 GpuAtomicAdd(bfloat16 *ptr, bfloat16 value) {
  return detail::GpuAtomicCasHelper(
      ptr, [value](bfloat16 a) { return a + value; });
}

__global__ void GatherBFloat16GradKernel(const bfloat16 *grad,
                                         const int *indices,
                                         bfloat16 *params_grad,
                                         int slice_size) {
  int i = threadIdx.x;
  if (i < slice_size) {
    int idx = indices[0];
    GpuAtomicAdd(&params_grad[idx * slice_size + i], grad[i]);
  }
}

}  // namespace

void GatherBFloat16Grad(const float *grad, int index, float *params_grad,
                        int num_slices, int slice_size) {
  bfloat16 *d_grad;
  int *d_indices;
  bfloat16 *d_params_grad;

  int total_params = num_slices * slice_size;
  cudaMallocManaged(&d_grad, sizeof(bfloat16) * slice_size);
  cudaMallocManaged(&d_indices, sizeof(int));
  cudaMallocManaged(&d_params_grad, sizeof(bfloat16) * total_params);

  *d_indices = index;
  for (int i = 0; i < slice_size; ++i) {
    d_grad[i] = FloatToBFloat16(grad[i]);
  }
  for (int i = 0; i < total_params; ++i) {
    d_params_grad[i] = bfloat16();
  }

  GatherBFloat16GradKernel<<<1, slice_size>>>(d_grad, d_indices, d_params_grad,
                                              slice_size);
  cudaDeviceSynchronize();

  for (int i = 0; i < total_params; ++i) {
    params_grad[i] = BFloat16ToFloat(d_params_grad[i]);
  }

  cudaFree(d_grad);
  cudaFree(d_indices);
  cudaFree(d_params_grad);
}
