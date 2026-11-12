# Hermetic Toolchains for ML

`rules_ml_toolchain` provides toolchains for ML projects to achieve reproducible, consistent, and isolated builds across Linux, macOS, and Windows.

Hermetic builds benefits:
* **Reproducibility**: Every build produces identical results regardless of the developer's machine environment.
* **Consistency**: Eliminates "works on my machine" issues, ensuring builds are consistent across different development environments.
* **Isolation**: Compilers, linkers, runtimes, interpreters, and sysroots are isolated from the host system, minimizing unexpected dependencies and side effects.

## Provided Hermetic Toolchains

This project provides hermetic toolchains for **C++**, **Python**, **Fortran**, and **GPU**:

* **[C++ Toolchains (`cc/README.md`)](cc/README.md)**: Hermetic LLVM/Clang C++ toolchains and sysroots for Linux (`x86_64`, `aarch64`), macOS (`aarch64`), and Windows (`x86_64`), including support for `libstdc++` and `libc++` linking, [sanitizers (ASan, TSan)](cc/sanitizers/README.md), cross-compilation, and Clang header modules.
* **[Python Toolchains (`py/README.md`)](py/README.md)**: Hermetic CPython interpreters (`3.11`, `3.12`, `3.13`, `3.14`, including free-threaded builds), locked PyPI dependency management, and [Pywrap rules (`rules_pywrap`)](py/rules_pywrap/README.md) for building C++/Python (`pybind11`) bindings.
* **[Fortran Toolchains (`fortran/README.md`)](fortran/README.md)**: Hermetic LLVM `flang` toolchains for building Fortran targets and mixed Fortran/C/C++ libraries (such as BLAS and LAPACK) on Linux (`x86_64`, `aarch64`), macOS (`aarch64`), and Windows (`x86_64`).
* **[GPU Toolchains (`gpu/README.md`)](gpu/README.md)**: Hermetic GPU toolchains and redistributables for NVIDIA CUDA, CUDNN, NCCL, and NVSHMEM, AMD ROCm, and Intel oneAPI SYCL.
