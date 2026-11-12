# Hermetic Fortran Toolchains for ML

This package provides hermetic `flang` toolchains for building Fortran targets and mixed Fortran/C/C++ libraries (such as BLAS and LAPACK) in ML projects, designed to work with [`rules_fortran`](https://github.com/miinso/rules_fortran).

Fortran hermetic builds benefits:
* Reproducibility: Every build produces identical results regardless of the developer's machine environment.
* Consistency: Eliminates "works on my machine" issues across Linux, macOS, and Windows environments.
* Isolation: Builds use hermetic LLVM `flang` compilers, runtimes, and sysroots isolated from the host system.

## Configure Fortran toolchains in rules_ml_toolchain

### Using Bzlmod (`MODULE.bazel`)

Fortran build rules (`fortran_library`, `fortran_binary`, `fortran_test`) are provided by [`rules_fortran`](https://github.com/miinso/rules_fortran), while `rules_ml_toolchain` provides the hermetic `flang` toolchains.

Add the following configuration to your `MODULE.bazel` file to configure [`rules_fortran`](https://github.com/miinso/rules_fortran) with `rules_ml_toolchain` and register both C++ and Fortran toolchains:

```starlark
bazel_dep(name = "rules_ml_toolchain", version = "0.0.0")

bazel_dep(name = "rules_fortran")
git_override(
    module_name = "rules_fortran",
    commit = "f0cac73ebdcbda7bc01b38b8a4ee33869416c220",
    patch_strip = 1,
    patches = [
        "@rules_ml_toolchain//third_party/rules_fortran:toolchains.patch",
    ],
    remote = "https://github.com/miinso/rules_fortran.git",
)

register_toolchains(
    "@rules_ml_toolchain//cc:all",
    "@rules_ml_toolchain//fortran:all",
)
```

> **Note:** `toolchains.patch` aliases `@rules_fortran//fortran:toolchain_type` to `@rules_ml_toolchain//fortran:toolchain_type` and removes `rules_fortran`'s default toolchain registration so that `rules_ml_toolchain`'s hermetic `flang` toolchains are resolved instead.

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

Hermetic Fortran builds require **LLVM `20` or newer**:
* **Why LLVM 20+ is required:** LLVM `20` is the first release where the `flang` driver supports the flags needed for hermetic compilation and linking:
  * `--no-default-config`: Ignores host and user default configuration files.
  * `-fno-rtlib-add-rpath`: Prevents baking host compiler runtime `RPATH` entries into outputs.
  * `-nostdlib` and `-nodefaultlibs`: Prevents linking against host system standard and default libraries.
  * `-w`: Suppresses warnings when compiling third-party Fortran libraries (such as Netlib BLAS and LAPACK).
  * Earlier versions (LLVM `18` and `19`) do not support these flags in `flang-new` and are blocked by the Fortran toolchain.

By default in `rules_ml_toolchain`:
* Linux and macOS toolchains default to LLVM `18` (for C++) and the `linux_glibc_2_27` sysroot, so you **must** specify `LLVM_VERSION=20` (or `21`, `22`) when building Fortran targets on Linux or macOS.
* Windows x86_64 toolchain defaults to LLVM `22` (the first official upstream LLVM Windows release bundling `flang`).

Specify the required LLVM version (`20` or newer) and sysroot distribution in your `.bazelrc` file:

```
common --enable_platform_specific_config

build:linux --repo_env=LLVM_VERSION=20
build:linux --repo_env=SYSROOT_DIST=linux_glibc_2_31
build:macos --repo_env=LLVM_VERSION=20
```

Supported versions of LLVM with Fortran (`flang`):

| Version | Linux x86_64 | Linux aarch64 | macOS aarch64 | Windows x86_64 |
|---------|--------------|---------------|---------------|----------------|
| 20      | x            | x             | x             |                |
| 21      | x            | x             | x             |                |
| 22      | x            | x             |               | x              |

Available Linux sysroots:

| Name             | Architecture    | GCC    | GLIBC | C++ Standard          | Used OS      |
|------------------|-----------------|--------|-------|-----------------------|--------------|
| linux_glibc_2_27 | x86_64, aarch64 | GCC 8  | 2.27  | C++17                 | Ubuntu 18.04 |
| linux_glibc_2_31 | x86_64, aarch64 | GCC 10 | 2.31  | C++20                 | Ubuntu 20.04 |
| linux_glibc_2_35 | x86_64          | GCC 12 | 2.35  | C++23 partial support | Ubuntu 22.04 |
| linux_glibc_2_39 | x86_64          | GCC 14 | 2.39  | C++23 near complete   | Ubuntu 24.04 |

## Fortran rules usage

Fortran rules are provided by [`rules_fortran`](https://github.com/miinso/rules_fortran). Load `fortran_library`, `fortran_binary`, and `fortran_test` from `@rules_fortran//:defs.bzl`:

```starlark
load(
    "@rules_fortran//:defs.bzl",
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
* `fortran_library`, `fortran_binary`, and `fortran_test` accept C/C++ (`cc_library`) dependencies directly via `deps`.

```starlark
cc_test(
    name = "cc_calls_fortran_test",
    srcs = [
        "cc_calls_fortran_test.cc",
        "math_mod.h",
    ],
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

`bazel test --repo_env=LLVM_VERSION=20 //fortran/tests:all`

### BLAS and LAPACK examples
Standalone examples demonstrating Netlib BLAS, LAPACK, LAPACKE C/C++ interop, and OpenMP are available in [`../third_party/rules_fortran/examples/`](../third_party/rules_fortran/examples/):

`bazel test --repo_env=LLVM_VERSION=20 //third_party/rules_fortran/examples/blas:main //third_party/rules_fortran/examples/lapack:chol //third_party/rules_fortran/examples/lapack:lu //third_party/rules_fortran/examples/lapack:mixed //third_party/rules_fortran/examples/lapack:svd`

### Cross-platform builds
Project supports cross-compiling Fortran targets from a Linux x86_64 executor to Linux aarch64:

`bazel build --repo_env=LLVM_VERSION=20 //fortran/tests/... --platforms=//common:linux_aarch64`

## Troubleshooting
Encountering issues? Try to find a solution on the [How To Fix](../HOW-TO-FIX.md) page.
