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

#ifndef NCCL_CUDA_CU_H_
#define NCCL_CUDA_CU_H_

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

int NcclDeviceVectorAdd(int size);

#endif  // NCCL_CUDA_CU_H_
