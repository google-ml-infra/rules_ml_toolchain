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

#include "bfloat16_atomic_add_cuda.cu.h"
#if __has_include(<bit>)
#include <bit>
#endif
#include <cmath>
#include <stdint.h>

#if defined(__NVCC__)
// Promote cross-execution-space call warnings to errors so build-only CI also
// catches if std::bit_cast<half> or std::signbit(float) is treated as a
// __host__-only function.
#pragma nv_diag_error 20011
#pragma nv_diag_error 20014
#endif

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

// Matches Eigen::bfloat16_impl::float_to_bfloat16_rtne in
// Eigen/src/Core/arch/Default/BFloat16.h.
template <bool AssumeArgumentIsNormalOrInfinityOrZero>
__host__ __device__ inline bfloat16 FloatToBFloat16Rtne(float ff);

template <>
__host__ __device__ inline bfloat16 FloatToBFloat16Rtne<true>(float ff) {
  uint32_t input = bit_cast<uint32_t>(ff);
  bfloat16 output;
  uint32_t lsb = (input >> 16) & 1;
  uint32_t rounding_bias = 0x7fff + lsb;
  input += rounding_bias;
  output.value = static_cast<uint16_t>(input >> 16);
  return output;
}

template <>
__host__ __device__ inline bfloat16 FloatToBFloat16Rtne<false>(float ff) {
  bfloat16 output;
  if (std::isnan(ff)) {
    // If the value is a NaN, squash it to a qNaN with msb of fraction set,
    // this makes sure after truncation we don't end up with an inf.
    output.value = std::signbit(ff) ? 0xFFC0 : 0x7FC0;
  } else {
    output = FloatToBFloat16Rtne<true>(ff);
  }
  return output;
}

__host__ __device__ inline bfloat16 FloatToBFloat16(float f) {
  return FloatToBFloat16Rtne<false>(f);
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

__device__ inline float HalfToFloat(half h) {
  float f;
  asm("cvt.f32.f16 %0, %1;" : "=f"(f) : "h"(h.x));
  return f;
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

// Reproduces TensorFlow's SaturateCastTest.testSaturateHandlesInfs
// (cast_op_test_gpu) from float16 (Eigen::half) to bfloat16 (Eigen::bfloat16):
// cvt.f32.f16 turns any half NaN (0x7e00 / 0xfe00) into the canonical 32-bit
// NaN 0x7fffffff, which FloatToBFloat16Rtne<false> must preserve as a quiet NaN
// via std::isnan and std::signbit rather than rounding 0x7fffffff + 0x8000 to
// 0x8000 (-0.0, finite).
__global__ void SaturateCastHalfToBFloat16Kernel(const half *in,
                                                 bool *out_is_finite,
                                                 int count) {
  int i = threadIdx.x;
  if (i < count) {
    float f = HalfToFloat(in[i]);
    // Clamp [-inf, inf] to float16 range [-65504, 65504] while preserving NaNs.
    float clipped = f > 65504.0f ? 65504.0f : (f < -65504.0f ? -65504.0f : f);
    bfloat16 bf = FloatToBFloat16(clipped);
    out_is_finite[i] = std::isfinite(BFloat16ToFloat(bf));
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

void SaturateCastHalfToBFloat16(const uint16_t *in_half_bits,
                                bool *out_is_finite, int count) {
  half *d_in;
  bool *d_out;
  cudaMallocManaged(&d_in, sizeof(half) * count);
  cudaMallocManaged(&d_out, sizeof(bool) * count);

  for (int i = 0; i < count; ++i) {
    d_in[i].x = in_half_bits[i];
  }

  SaturateCastHalfToBFloat16Kernel<<<1, count>>>(d_in, d_out, count);
  cudaDeviceSynchronize();

  for (int i = 0; i < count; ++i) {
    out_is_finite[i] = d_out[i];
  }

  cudaFree(d_in);
  cudaFree(d_out);
}
