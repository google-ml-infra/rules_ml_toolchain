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

"""ROCm library rule that compiles GPU code and creates a cc_library."""

load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("//cc/rocm:rocm_compile.bzl", "rocm_compile")

def rocm_library(name, srcs = [], hdrs = [], copts = [], deps = [], linkopts = [], local_defines = [], **kwargs):
    """Compiles ROCm sources with hipcc, wraps .o files in cc_library for linking.

    Args:
        name: Name of the library
        srcs: Source files to compile (.cu.cc, .cc)
        hdrs: Header files (.h, .cu.h)
        copts: Compiler options
        deps: Dependencies
        linkopts: Linker options
        local_defines: Preprocessor defines (will be passed as -DNAME)
        **kwargs: Additional arguments passed to cc_library
    """
    compiled_objects = []
    if srcs:
        # Convert local_defines to copts with -D prefix
        define_copts = ["-D" + d for d in local_defines]
        all_copts = copts + define_copts

        rocm_compile(
            name = name + "_rocm_objects",
            srcs = srcs,
            hdrs = hdrs,
            deps = deps,
            copts = all_copts,
        )
        compiled_objects.append(":" + name + "_rocm_objects")

    # Allow duplicate weak symbols (__hip_cuid_) from multiple compilations of same source
    rocm_linkopts = ["-Wl,--allow-multiple-definition"] + linkopts

    cc_library(
        name = name,
        hdrs = hdrs,
        srcs = compiled_objects,
        deps = deps,
        copts = copts,
        linkopts = rocm_linkopts,
        **kwargs
    )
