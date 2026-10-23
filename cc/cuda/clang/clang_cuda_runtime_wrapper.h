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
==============================================================================*/

#ifndef __CLANG_CUDA_RUNTIME_WRAPPER_H
#define __CLANG_CUDA_RUNTIME_WRAPPER_H

#if defined (CLANG_CUDA) && (CLANG_CUDA == 1)
#include <__clang_cuda_runtime_wrapper.h>
#endif

// In C++20 mode, Eigen::numext::bit_cast delegates to std::bit_cast, which in
// libc++ is a constexpr host function template without __host__ __device__.
// Normally --expt-relaxed-constexpr implicitly treats constexpr host functions
// as __host__ __device__. However, when _ToType is trivially copyable but not
// a literal type (e.g., Eigen::half, whose default constructor is not constexpr
// when EIGEN_HAS_GPU_FP16 is enabled), NVCC's EDG frontend drops constexpr from
// that specialization under pre-C++23 rules, turning it into a __host__-only
// function. Calling it from a __host__ __device__ function in a system header
// then silently compiles to a null function pointer call in device PTX.
// Redeclaring std::bit_cast with __host__ __device__ ensures NVCC always emits
// the device implementation.
#if defined(__CUDACC__) && defined(__NVCC__) && __cplusplus >= 202002L
#pragma GCC system_header
#include <bit>
#if defined(_LIBCPP_VERSION)
_LIBCPP_BEGIN_NAMESPACE_STD
template <class _ToType, class _FromType>
  requires(sizeof(_ToType) == sizeof(_FromType) && is_trivially_copyable_v<_ToType> &&
           is_trivially_copyable_v<_FromType>)
[[nodiscard]] _LIBCPP_HIDE_FROM_ABI __host__ __device__ constexpr _ToType bit_cast(const _FromType& __from) noexcept;
_LIBCPP_END_NAMESPACE_STD
#endif
#endif

#endif //__CLANG_CUDA_RUNTIME_WRAPPER_H
