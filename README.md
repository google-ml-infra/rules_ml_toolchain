# Hermetic Toolchains for ML

`rules_ml_toolchain` provides Bazel rules and hermetic toolchains for ML projects to achieve reproducible, consistent, and isolated builds across Linux, macOS, and Windows.

Hermetic builds benefits:
* **Reproducibility**: Every build produces identical results regardless of the developer's machine environment.
* **Consistency**: Eliminates "works on my machine" issues, ensuring builds are consistent across different development environments.
* **Isolation**: Compilers, linkers, runtimes, interpreters, and sysroots are isolated from the host system, minimizing unexpected dependencies and side effects.

## Provided Hermetic Toolchains

This repository provides hermetic toolchains for **C++**, **Python**, **Fortran**, and **GPUs**:

* **[C++ Toolchains (`//cc`)](cc/README.md)**: Hermetic LLVM/Clang C++ toolchains and sysroots for Linux (`x86_64`, `aarch64`), macOS (`aarch64`), and Windows (`x86_64`), including support for `libstdc++` and `libc++` linking, [sanitizers (ASan, TSan)](cc/sanitizers/README.md), cross-compilation, and Clang header modules.
* **[Python Toolchains (`//py`)](py/README.md)**: Hermetic CPython interpreters (`3.11`, `3.12`, `3.13`, `3.14`, including free-threaded builds), locked PyPI dependency management, and [Pywrap rules (`rules_pywrap`)](py/rules_pywrap/README.md) for building C++/Python (`pybind11`) bindings.
* **[Fortran Toolchains (`//fortran`)](fortran/README.md)**: Hermetic LLVM `flang` toolchains for building Fortran targets and mixed Fortran/C/C++ libraries (such as BLAS and LAPACK) on Linux (`x86_64`, `aarch64`), macOS (`aarch64`), and Windows (`x86_64`).
* **[GPU Toolchains (`//gpu`)](gpu/README.md)**: Hermetic GPU toolchains and redistributables for NVIDIA CUDA, CUDNN, NCCL, and NVSHMEM, AMD ROCm, and Intel oneAPI SYCL.

## Quick Start

### Using Bzlmod (`MODULE.bazel`)

```starlark
bazel_dep(name = "rules_ml_toolchain", version = "0.0.0")

register_toolchains(
    "@rules_ml_toolchain//cc:all",
    "@rules_ml_toolchain//fortran:all",
)
```

### Using `WORKSPACE`

```starlark
load(
    "@rules_ml_toolchain//common/deps:toolchain_deps.bzl",
    "toolchain_deps",
)

toolchain_deps()

register_toolchains(
    "@rules_ml_toolchain//cc:all",
    "@rules_ml_toolchain//fortran:all",
)
```

For detailed setup and configuration instructions for each language or accelerator, refer to:
* [C++ Toolchain Documentation](cc/README.md)
* [Python Toolchain Documentation](py/README.md)
* [Fortran Toolchain Documentation](fortran/README.md)
* [GPU Toolchain Documentation](gpu/README.md)

## Troubleshooting
Encountering issues? Try to find a solution on the [How To Fix](HOW-TO-FIX.md) page.
