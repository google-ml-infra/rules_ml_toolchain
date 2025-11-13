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

#include <cassert>
#include <omp.h>
#include <stdio.h>
#include <string>
#include <vector>

#include "gtest/gtest.h"

TEST(OpenMPTest, OpenMPTest) {
    // --- Example 1: Basic Parallel Region and Thread ID ---
    printf("--- OpenMP Example ---\n");
#pragma omp parallel // Defines a parallel region
    {
        int thread_id = omp_get_thread_num(); // Get current thread's ID
        printf("Thread %d!\n", thread_id);
    }

    // --- Example 2: Parallelized Loop with Reduction ---
    printf("\n--- OpenMP Parallel Loop Example ---\n");
    const int n = 100;
    int arr[n];
    for (int i = 0; i < n; i++) {
        arr[i] = i + 1; // Initialize array with values 1 to 100
    }

    long long sum = 0;
#pragma omp parallel for reduction(+:sum) // Parallelize the loop and perform a reduction sum

    for (int i = 0; i < n; i++) {
        sum += arr[i];
    }

    printf("Sum of array elements (1 to %d) = %lld\n", n, sum);
}