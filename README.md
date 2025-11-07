# Hermetic Toolchains for ML

This project provides Bazel rules for ML project to achieve hermetic builds.

C++ and CUDA hermetic builds benefits:
* Reproducibility: Every build produces identical results regardless of the developer's machine environment.
* Consistency: Eliminates "works on my machine" issues, ensuring builds are consistent across different development environments.
* Isolation: Builds are isolated from the host system, minimizing unexpected dependencies and side effects.

<!--
C++ cross-platform builds benefits:
* Single Source of Truth: Develop and maintain a single codebase that can be built for various target platforms (e.g., Linux, macOS).
* Efficiency: Streamlines the build and release process for multiple platforms.
-->

## Configure C++ toolchains in rules_ml_toolchain

Add the following code to WORKSPACE file:

```
http_archive(
    name = "rules_ml_toolchain",
    sha256 = "dd6035b2aa22ec22c7598c0c78d1f593a74606d787d1059d19ab0f9b581e513d",
    strip_prefix = "rules_ml_toolchain-4d9fa39eda9c769db86770a13ce2c2e2090bced8",
    urls = [
        "https://github.com/google-ml-infra/rules_ml_toolchain/archive/4d9fa39eda9c769db86770a13ce2c2e2090bced8.tar.gz",
    ],
)

load(
    "@rules_ml_toolchain//cc/deps:cc_toolchain_deps.bzl",
    "cc_toolchain_deps",
)

cc_toolchain_deps()

register_toolchains("@rules_ml_toolchain//cc:linux_x86_64_linux_x86_64")
register_toolchains("@rules_ml_toolchain//cc:linux_aarch64_linux_aarch64")
```

If CUDA or SYCL initialization is required, ensure this block is inserted before either initialization occurs.

It must be ensured that builds for Linux x86_64 / aarch64 are run without the `--noincompatible_enable_cc_toolchain_resolution`
flag. Furthermore, reliance on environment variables like `CLANG_COMPILER_PATH`, `BAZEL_COMPILER`, `CC`, or `CXX`
must be avoided.

For diagnosing the utility set being used during build or test execution, the `--subcommands` flag should be appended
to the Bazel command. This will facilitate checking that the compiler or linker are not being used from your machine.

## Configure hermetic CUDA, CUDNN, NCCL and NVSHMEM
For detailed instructions on how to configure hermetic CUDA, CUDNN, NCCL and NVSHMEM, [click this link](gpu/).

## Configure the LLVM / Sysroot in rules_ml_toolchain

LLVM `18` and the `linux_glibc_2_27` sysroot are used for compilation by default.
To change these defaults, specify the required LLVM version and sysroot distribution in `.bazelrc` file.

For example, to configure LLVM `20` with `linux_glibc_2_31`, update your `.bazelrc` with below lines
```
common --enable_platform_specific_config

build:linux --repo_env=LLVM_VERSION=20
build:linux --repo_env=SYSROOT_DIST=linux_glibc_2_31
```

Supported versions of LLVM

| Version | Linux x86_64 | Linux aarch64 | macOS aarch64 |
|---------|--------------|---------------|---------------|
| 18      | x | x | x             |
| 19      | x |   |               |
| 20      | x | x |               |
| 21      | x |   |               |

Available sysroots

| Name             | Architecture    | GCC    | GLIBC | C++ Standard          | Used OS      |
|------------------|-----------------|--------|-------|-----------------------|--------------|
| linux_glibc_2_27 | x86_64, aarch64 | GCC 8   | 2.27  | C++17                 | Ubuntu 18.04 |
| linux_glibc_2_31 | x86_64, aarch64 | GCC 10  | 2.31  | C++20                 | Ubuntu 20.04 |
| linux_glibc_2_35 | x86_64          | GCC 12  | 2.35  | C++23 partial support | Ubuntu 22.04 |

## Run rules_ml_toolchain tests
### CPU hermetic tests
Project supports CPU hermetic builds on:
* Linux x86_64 / aarch64
* macOS aarch64 - *In Development*

The command allows you to run hermetic build tests:

`bazel test //cc/tests/cpu:all`

#### Non-hermetic CPU builds
When executor and a target are the same, you still can run non-hermetic build. Command should look like:

`bazel build //cc/tests/cpu:all --config=clang_local`

For details, look at the `.bazelrc` file, specifically the `clang_local` configuration.

### CUDA and hermetic toolchains tests
Project supports GPU hermetic builds on Linux x86_64 / aarch64. Running tests requires a machine with an NVIDIA GPU.

Hermetic tests could be run with the help of the command:
###### Build by Clang
`bazel test //cc/tests/gpu:all --config=build_cuda_with_clang --config=cuda --config=cuda_libraries_from_stubs`

###### Build by NVCC
`bazel test //cc/tests/gpu:all --config=build_cuda_with_nvcc --config=cuda --config=cuda_libraries_from_stubs`

#### CUDA and non-hermetic toolchains tests
When the executor and the target are the same, a non-hermetic GPU build can still be run.

###### Build by Clang
`bazel test //cc/tests/gpu:all --config=build_cuda_with_clang --config=cuda_clang_local --config=cuda_libraries_from_stubs`

###### Build by NVCC
`bazel test //cc/tests/gpu:all --config=build_cuda_with_nvcc --config=cuda_clang_local --config=cuda_libraries_from_stubs`

For details, look at the `.bazelrc` file, specifically the `cuda_clang_local` configuration.

<!--
### Cross-platform builds
Project supports cross-platform builds only on Linux x86_64 executor 
and allows build for such targets:
* Linux aarch64
* macOS aarch64

#### Build for Linux aarch64
`bazel build //cc/tests/cpu/... --platforms=//common:linux_aarch64`

#### Build for macOS aarch64
[Prepare SDK](cc/sysroots/darwin_aarch64/README.md) before run the following command.

`bazel build //cc/tests/cpu/... --platforms=//common:macos_aarch64`
-->

## Troubleshooting
Encountering issues? Try to find decision on [How To Fix](HOW-TO-FIX.md) page.
