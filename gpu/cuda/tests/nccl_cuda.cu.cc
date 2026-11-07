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

#include "nccl_cuda.cu.h"
#include "third_party/nccl/nccl_device.h"
#include "third_party/nccl/nccl_device/gin/gpi/gin_gpi_device_host_common.h"

namespace {

__global__ void NcclDeviceAddKernel(const int *a, const int *b, int *c, int n) {
  int i = threadIdx.x;
  if (i < n) {
    c[i] = GPI_READ_ONCE(a[i]) + GPI_READ_ONCE(b[i]);
  }
}

}  // namespace

int NcclDeviceVectorAdd(int size) {
  int *a, *b, *c;

  cudaMallocManaged(&a, sizeof(int) * size);
  cudaMallocManaged(&b, sizeof(int) * size);
  cudaMallocManaged(&c, sizeof(int) * size);

  for (int i = 0; i < size; ++i) {
    a[i] = i + 1;
    b[i] = i + 1;
    c[i] = 0;
  }

  NcclDeviceAddKernel<<<1, size>>>(a, b, c, size);
  cudaDeviceSynchronize();

  int sum = 0;
  for (int i = 0; i < size; ++i) {
    sum += c[i];
  }

  cudaFree(a);
  cudaFree(b);
  cudaFree(c);

  return sum;
}
