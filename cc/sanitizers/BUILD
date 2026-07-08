# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load(":sanitizer_wrapper.bzl", "sanitizer_wrapper")

package(
    default_visibility = ["//visibility:public"],
)

exports_files([
    "sanitizer_wrapper.bzl",
    "features.bzl",
])

# Linux x86_64 sanitizer wrapper using hermetic LLVM toolchain
# Basic wrapper with common ASAN/TSAN options, no suppression lists
sanitizer_wrapper(
    name = "sanitizer_wrapper_linux_x86_64",
    llvm_symbolizer = "@llvm_linux_x86_64//:llvm-symbolizer",
    asan_options = "detect_leaks=0",
    tsan_options = "halt_on_error=1:exitcode=66",
    # Include distro libs needed by llvm-symbolizer
    additional_data = ["@llvm_linux_x86_64//:distro_libs"],
    visibility = ["//visibility:public"],
)

# Linux aarch64 sanitizer wrapper
# Basic wrapper with common ASAN/TSAN options, no suppression lists
sanitizer_wrapper(
    name = "sanitizer_wrapper_linux_aarch64",
    llvm_symbolizer = "@llvm_linux_aarch64//:llvm-symbolizer",
    asan_options = "detect_leaks=0",
    tsan_options = "halt_on_error=1:exitcode=66",
    visibility = ["//visibility:public"],
)

# ROCm sanitizer wrapper using hermetic LLVM toolchain
# ROCm builds use @llvm_linux_x86_64 as host compiler, so use its symbolizer
# Basic wrapper with common ASAN/TSAN options, no suppression lists
sanitizer_wrapper(
    name = "sanitizer_wrapper_rocm",
    llvm_symbolizer = "@llvm_linux_x86_64//:llvm-symbolizer",
    asan_options = "detect_leaks=0",
    tsan_options = "halt_on_error=1:exitcode=66",
    # Include distro libs needed by llvm-symbolizer
    additional_data = ["@llvm_linux_x86_64//:distro_libs"],
    visibility = ["//visibility:public"],
)
