load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

package(default_visibility = ["//visibility:public"])

# Intel(R) Software Development Tools Licensed under the Intel End User License Agreement for Developer Tools (Version August 2024)
# Tools -> Intel(R) oneAPI DPC++/C++ Compiler, Intel(R) Vtune(TM) Profiler
# Intel(R) Software Development Tools Licensed under the Intel Simplified Software License (Version October 2022)
# Tools -> oneAPI Math Kernel Library (oneMKL)
# Intel(R) Software Development Tools Licensed under Open Source Licenses Apache License, Version 2.0
# Tools -> oneAPI Deep Neural Network Library, Intel(R) oneAPI Data Analytics Library (oneDAL)
# Apache License, Version 2.0 with LLVM Exception -- Tools ->Intel(R) oneAPI DPC++/C++ Compiler,Intel(R) oneAPI DPC++ Library (oneDPL)
# The GNU General Public License v3.0 -> Tools-- Intel(R) Distribution for GDB*
licenses(["restricted"])

# To support non-hermetic build.
bzl_library(
    name = "build_defs_bzl",
    srcs = ["build_defs.bzl"],
    visibility = ["//visibility:public"],
)
