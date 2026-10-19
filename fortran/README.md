# Hermetic Fortran Toolchains for ML

This package provides Bazel rules and hermetic `flang` toolchains for building Fortran targets and mixed Fortran/C/C++ libraries (such as BLAS and LAPACK) in ML projects.

Fortran hermetic builds benefits:
* Reproducibility: Every build produces identical results regardless of the developer's machine environment.
* Consistency: Eliminates "works on my machine" issues across Linux, macOS, and Windows environments.
* Isolation: Builds use hermetic LLVM `flang` compilers, runtimes, and sysroots isolated from the host system.

## Configure Fortran toolchains in rules_ml_toolchain

### Using Bzlmod (`MODULE.bazel`)

Add the following configuration to your `MODULE.bazel` file to register both C++ and Fortran toolchains:

```starlark
bazel_dep(name = "rules_ml_toolchain", version = "0.0.0")

register_toolchains(
    "@rules_ml_toolchain//cc/...",
    "@rules_ml_toolchain//fortran/...",
)
```

### Using `WORKSPACE`

Add the following code to your `WORKSPACE` file:

```starlark
load(
    "@rules_ml_toolchain//common/deps:toolchain_deps.bzl",
    "toolchain_deps",
)

toolchain_deps()

register_toolchains("@rules_ml_toolchain//cc:linux_x86_64_linux_x86_64")
register_toolchains("@rules_ml_toolchain//cc:linux_aarch64_linux_aarch64")
register_toolchains("@rules_ml_toolchain//fortran:linux_x86_64_linux_x86_64")
register_toolchains("@rules_ml_toolchain//fortran:linux_aarch64_linux_aarch64")
register_toolchains("@rules_ml_toolchain//fortran:darwin_aarch64_darwin_aarch64")
register_toolchains("@rules_ml_toolchain//fortran:windows_x86_64_windows_x86_64")
```

For diagnosing the compiler and linker invocations during build or test execution, append the `--subcommands` flag to your Bazel command to verify that hermetic `flang` and `lld` binaries are used.

## Configure the LLVM / Sysroot in rules_ml_toolchain

By default:
* Linux and macOS toolchains use LLVM `18` and the `linux_glibc_2_27` sysroot.
* Windows x86_64 toolchain uses LLVM `22` (the first official upstream LLVM Windows release bundling `flang`).

To change these defaults, specify the required LLVM version and sysroot distribution in your `.bazelrc` file:

```
common --enable_platform_specific_config

build:linux --repo_env=LLVM_VERSION=20
build:linux --repo_env=SYSROOT_DIST=linux_glibc_2_31
```

Supported versions of LLVM with Fortran (`flang`):

| Version | Linux x86_64 | Linux aarch64 | macOS aarch64 | Windows x86_64 |
|---------|--------------|---------------|---------------|----------------|
| 18      | x            | x             | x             |                |
| 19      | x            | x             | x             |                |
| 20      | x            | x             | x             |                |
| 21      | x            | x             |               |                |
| 22      | x            | x             |               | x              |

Available Linux sysroots:

| Name             | Architecture    | GCC    | GLIBC | C++ Standard          | Used OS      |
|------------------|-----------------|--------|-------|-----------------------|--------------|
| linux_glibc_2_27 | x86_64, aarch64 | GCC 8  | 2.27  | C++17                 | Ubuntu 18.04 |
| linux_glibc_2_31 | x86_64, aarch64 | GCC 10 | 2.31  | C++20                 | Ubuntu 20.04 |
| linux_glibc_2_35 | x86_64          | GCC 12 | 2.35  | C++23 partial support | Ubuntu 22.04 |
| linux_glibc_2_39 | x86_64          | GCC 14 | 2.39  | C++23 near complete   | Ubuntu 24.04 |

## Fortran rules usage

Load `fortran_library`, `fortran_binary`, and `fortran_test` from `@rules_ml_toolchain//fortran:defs.bzl`:

```starlark
load(
    "@rules_ml_toolchain//fortran:defs.bzl",
    "fortran_binary",
    "fortran_library",
    "fortran_test",
)

fortran_library(
    name = "math_mod",
    srcs = ["math_mod.f90"],
    visibility = ["//visibility:public"],
)

fortran_binary(
    name = "app",
    srcs = ["main.f90"],
    deps = [":math_mod"],
)

fortran_test(
    name = "math_mod_test",
    srcs = ["math_mod_test.f90"],
    deps = [":math_mod"],
)
```

### C / C++ Interoperability (`iso_c_binding`)

* `fortran_library` produces `CcInfo`, allowing `cc_library`, `cc_binary`, and `cc_test` targets to depend directly on Fortran targets via `deps`.
* `fortran_library`, `fortran_binary`, and `fortran_test` accept C/C++ dependencies via `cc_deps`.

```starlark
cc_test(
    name = "cc_calls_fortran_test",
    srcs = ["cc_calls_fortran_test.cc"],
    deps = [":math_mod"],
)
```

## Run Fortran toolchain tests and examples

### Fortran hermetic tests
Project supports hermetic Fortran builds and tests on:
* Linux x86_64 / aarch64
* macOS aarch64
* Windows x86_64

Run the Fortran test suite with:

`bazel test //fortran/tests:all`

### BLAS and LAPACK examples
Standalone examples demonstrating Netlib BLAS, LAPACK, LAPACKE C/C++ interop, and OpenMP are available in [`examples/`](examples/):

`cd fortran/examples && bazel test //blas/... //lapack/...`

### Cross-platform builds
Project supports cross-compiling Fortran targets from a Linux x86_64 executor to Linux aarch64:

`bazel build //fortran/tests/... --platforms=//common:linux_aarch64`

## Troubleshooting
Encountering issues? Try to find a solution on the [How To Fix](../HOW-TO-FIX.md) page.
