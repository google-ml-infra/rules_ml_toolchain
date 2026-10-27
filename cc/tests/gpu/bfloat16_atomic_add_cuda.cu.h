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

#ifndef BFLOAT16_ATOMIC_ADD_CUDA_H
#define BFLOAT16_ATOMIC_ADD_CUDA_H

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdint.h>

void GatherBFloat16Grad(const float *grad, int index, float *params_grad,
                        int num_slices, int slice_size);

void SaturateCastHalfToBFloat16(const uint16_t *in_half_bits,
                                bool *out_is_finite, int count);

#endif  // BFLOAT16_ATOMIC_ADD_CUDA_H
