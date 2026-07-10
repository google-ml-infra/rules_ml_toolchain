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
    "sanitizer_wrapper.sh.tpl",
    "features.bzl",
])

# Default sanitizer wrapper
# Projects should create their own wrappers with custom ignore lists
sanitizer_wrapper(
    name = "sanitizer_wrapper",
    llvm_symbolizer = "@llvm_linux_x86_64//:llvm-symbolizer",
    asan_options = "detect_leaks=0",
    tsan_options = "halt_on_error=1:exitcode=66",
    additional_data = ["@llvm_linux_x86_64//:distro_libs"],
    visibility = ["//visibility:public"],
)
