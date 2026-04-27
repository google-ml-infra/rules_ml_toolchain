# Copyright 2026 Google LLC
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

"""ROCm library rule that compiles GPU code into standalone .so with ROCm's C++ runtime."""

load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("//cc/rocm:rocm_compile.bzl", "rocm_compile")

def rocm_library(name, srcs = [], hdrs = [], copts = [], deps = [], linkopts = [], local_defines = [], **kwargs):
    """Compiles ROCm sources into standalone .so with ROCm's libc++.

    Args:
        name: Name of the library
        srcs: Source files to compile (.cu.cc, .cc)
        hdrs: Header files (.h, .cu.h)
        copts: Compiler options
        deps: Dependencies
        linkopts: Linker options (ignored - rocm_compile handles linking)
        local_defines: Preprocessor defines (will be passed as -DNAME)
        **kwargs: Additional arguments passed to rocm_compile
    """
    if srcs:
        # Convert local_defines to copts with -D prefix
        define_copts = ["-D" + d for d in local_defines]
        all_copts = copts + define_copts

        # rocm_compile now compiles AND links into standalone .so
        rocm_compile(
            name = name,
            srcs = srcs,
            hdrs = hdrs,
            deps = deps,
            copts = all_copts,
            **kwargs
        )
    else:
        # Header-only library
        cc_library(
            name = name,
            hdrs = hdrs,
            deps = deps,
            **kwargs
        )
