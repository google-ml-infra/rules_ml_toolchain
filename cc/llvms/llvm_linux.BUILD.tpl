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
# ==============================================================================

alias(
    name = "all",
    actual = "@@%{llvm_repo_name}//:all",
    visibility = ["//visibility:public"],
)

alias(
    name = "clang",
    actual = "@@%{llvm_repo_name}//:clang",
    visibility = ["//visibility:public"],
)

alias(
    name = "clang++",
    actual = "@@%{llvm_repo_name}//:clang++",
    visibility = ["//visibility:public"],
)

alias(
    name = "ld",
    actual = "@@%{llvm_repo_name}//:ld",
    visibility = ["//visibility:public"],
)

alias(
    name = "ar",
    actual = "@@%{llvm_repo_name}//:ar",
    visibility = ["//visibility:public"],
)

# Used as single file target in NCCL
alias(
    name = "llvm-ar",
    actual = "@@%{llvm_repo_name}//:bin/llvm-ar",
    visibility = ["//visibility:public"],
)

alias(
    name = "ar_darwin",
    actual = "@@%{llvm_repo_name}//:ar_darwin",
    visibility = ["//visibility:public"],
)

alias(
    name = "objcopy",
    actual = "@@%{llvm_repo_name}//:objcopy",
    visibility = ["//visibility:public"],
)

alias(
    name = "llvm-objcopy",
    actual = "@@%{llvm_repo_name}//:bin/llvm-objcopy",
    visibility = ["//visibility:public"],
)

alias(
    name = "strip",
    actual = "@@%{llvm_repo_name}//:strip",
    visibility = ["//visibility:public"],
)

alias(
    name = "install_name_tool_darwin",
    actual = "@@%{llvm_repo_name}//:install_name_tool_darwin",
    visibility = ["//visibility:public"],
)

# LLVM18 needs libtinfo.so.5 library as part of ubuntu 18 distributive
alias(
    name = "distro_libs",
    actual = "@@%{llvm_repo_name}//:distro_libs",
    visibility = ["//visibility:public"],
)

alias(
    name = "asan_ignorelist",
    actual = "@@%{llvm_repo_name}//:asan_ignorelist",
    visibility = ["//visibility:public"],
)

alias(
    name = "includes",
    actual = "@@%{llvm_repo_name}//:includes",
    visibility = ["//visibility:public"],
)

# This library is needed for LiteRT because it uses a compiler-specific
# built-in functions, and these functions are not provided by GCC
alias(
    name = "libclang_rt",
    actual = "@@%{llvm_repo_name}//:libclang_rt",
    visibility = ["//visibility:public"],
)

# Use when build CUDA by Clang (NVCC doesn't need it)
alias(
    name = "cuda_wrappers_headers",
    actual = "@@%{llvm_repo_name}//:cuda_wrappers_headers",
    visibility = ["//visibility:public"],
)
