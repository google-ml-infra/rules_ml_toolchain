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

#include "vector_sycl.h"

int VectorGenerateAndSum(int size) {

    // Host data
    std::vector<float> a_h(size);
    std::vector<float> b_h(size);
    std::vector<float> c_h(size);

    // Initialize host data
    for (int i = 0; i < size; ++i) {
        a_h[i] = static_cast<float>(i);
        b_h[i] = static_cast<float>(i * 2);
    }

    // Create a SYCL queue targeting a default device (e.g., GPU if available)
    sycl::queue q;

    // Create SYCL buffers for device memory
    sycl::buffer<float, 1> a_buf(a_h.data(), sycl::range<1>(size));
    sycl::buffer<float, 1> b_buf(b_h.data(), sycl::range<1>(size));
    sycl::buffer<float, 1> c_buf(c_h.data(), sycl::range<1>(size));

    // Submit a command group to the queue
    q.submit([&](sycl::handler& h) {
        // Create accessors to buffers within the command group
        sycl::accessor a_acc(a_buf, h, sycl::read_only);
        sycl::accessor b_acc(b_buf, h, sycl::read_only);
        sycl::accessor c_acc(c_buf, h, sycl::write_only);

        // Define the kernel for vector addition
        h.parallel_for(sycl::range<1>(size), [=](sycl::id<1> idx) {
            c_acc[idx] = a_acc[idx] + b_acc[idx];
        });
    }).wait(); // Wait for the kernel to complete

    // Force copy back to host before verification
    sycl::host_accessor c_host(c_buf, sycl::read_only);

    // Verify results
    for (int i = 0; i < size; ++i) {
        if (c_host[i] != (a_h[i] + b_h[i])) {
            std::cout << "Error at index " << i << ": " << c_host[i]
                      << " != " << (a_h[i] + b_h[i]) << std::endl;
            return 1;
        }
    }

    std::cout << "Vector addition successful!" << std::endl;

    return 0;
}
