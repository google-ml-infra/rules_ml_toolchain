# Hermetic C++ Toolchains for ML

This package provides Bazel rules and hermetic LLVM/Clang C++ toolchains and sysroots for building C++ targets across Linux (`x86_64`, `aarch64`), macOS (`aarch64`), and Windows (`x86_64`).

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

### Using Bzlmod (`MODULE.bazel`)

Add the following to your `MODULE.bazel` file:

```starlark
bazel_dep(name = "rules_ml_toolchain")
archive_override(
    module_name = "rules_ml_toolchain",
    integrity = "sha256-bywqV064uobGw+nzpAUoTZyRWvpn6m4SwhCoFnY98Sk=",
    strip_prefix = "rules_ml_toolchain-ec70529c9a611b364f12d67f61f083524e445431",
    urls = [
        "https://github.com/google-ml-infra/rules_ml_toolchain/archive/ec70529c9a611b364f12d67f61f083524e445431.tar.gz",
    ],
)

register_toolchains("@rules_ml_toolchain//cc:linux_x86_64_linux_x86_64")
register_toolchains("@rules_ml_toolchain//cc:linux_x86_64_linux_aarch64")
register_toolchains("@rules_ml_toolchain//cc:linux_x86_64_darwin_aarch64")
register_toolchains("@rules_ml_toolchain//cc:linux_aarch64_linux_aarch64")
register_toolchains("@rules_ml_toolchain//cc:darwin_aarch64_darwin_aarch64")
register_toolchains("@rules_ml_toolchain//cc:windows_x86_64_windows_x86_64")
```

### Using `WORKSPACE`

Add the following code to WORKSPACE file:

```starlark
http_archive(
    name = "rules_ml_toolchain",
    sha256 = "6f2c2a574eb8ba86c6c3e9f3a405284d9c915afa67ea6e12c210a816763df129",
    strip_prefix = "rules_ml_toolchain-ec70529c9a611b364f12d67f61f083524e445431",
    urls = [
        "https://github.com/google-ml-infra/rules_ml_toolchain/archive/ec70529c9a611b364f12d67f61f083524e445431.tar.gz",
    ],
)

load(
    "@rules_ml_toolchain//common/deps:toolchain_deps.bzl",
    "toolchain_deps",
)

toolchain_deps()

register_toolchains("@rules_ml_toolchain//cc:linux_x86_64_linux_x86_64")
register_toolchains("@rules_ml_toolchain//cc:linux_x86_64_linux_aarch64")
register_toolchains("@rules_ml_toolchain//cc:linux_x86_64_darwin_aarch64")
register_toolchains("@rules_ml_toolchain//cc:linux_aarch64_linux_aarch64")
register_toolchains("@rules_ml_toolchain//cc:darwin_aarch64_darwin_aarch64")
register_toolchains("@rules_ml_toolchain//cc:windows_x86_64_windows_x86_64")
```

If CUDA or SYCL initialization is required, ensure this block is inserted before either initialization occurs.

It must be ensured that builds for Linux x86_64 / aarch64 are run without the `--noincompatible_enable_cc_toolchain_resolution`
flag. Furthermore, reliance on environment variables like `CLANG_COMPILER_PATH`, `BAZEL_COMPILER`, `CC`, or `CXX`
must be avoided.

For diagnosing the utility set being used during build or test execution, the `--subcommands` flag should be appended
to the Bazel command. This will facilitate checking that the compiler or linker are not being used from your machine.

## Configure hermetic CUDA, CUDNN, NCCL and NVSHMEM
For detailed instructions on how to configure hermetic CUDA, CUDNN, NCCL and NVSHMEM, [click this link](../gpu/README.md).

## Configure the LLVM / Sysroot in rules_ml_toolchain

LLVM `18` (for Linux and macOS), LLVM `22` (for Windows x86_64), and the `linux_glibc_2_27` sysroot are used for compilation by default.
To change these defaults, specify the required LLVM version and sysroot distribution in `.bazelrc` file.

For example, to configure LLVM `20` with `linux_glibc_2_31`, update your `.bazelrc` with below lines
```
common --enable_platform_specific_config

build:linux --repo_env=LLVM_VERSION=20
build:linux --repo_env=SYSROOT_DIST=linux_glibc_2_31
```

Supported versions of LLVM

| Version | Linux x86_64 | Linux aarch64 | macOS aarch64 | Windows x86_64 |
|---------|--------------|---------------|---------------|----------------|
| 18      | x | x             | x             |                |
| 19      | x | x             | x             |                |
| 20      | x | x             | x             |                |
| 21      | x | x             | x             |                |
| 22      | x | x             | x             | x              |

Available sysroots

| Name             | Architecture    | GCC    | GLIBC | C++ Standard          | Used OS      |
|------------------|-----------------|--------|-------|-----------------------|--------------|
| linux_glibc_2_27 | x86_64, aarch64 | GCC 8  | 2.27  | C++17                 | Ubuntu 18.04 |
| linux_glibc_2_31 | x86_64, aarch64 | GCC 10 | 2.31  | C++20                 | Ubuntu 20.04 |
| linux_glibc_2_35 | x86_64          | GCC 12 | 2.35  | C++23 partial support | Ubuntu 22.04 |
| linux_glibc_2_39 | x86_64          | GCC 14 | 2.39  | C++23 near complete   | Ubuntu 24.04 |

## Linking against `libstdc++` or `libc++` on Linux
By default, `rules_ml_toolchain` links dynamically against `libstdc++` for Linux builds.
However, you can choose to link against `libc++` instead, using dynamic or static linking.

> **Note:** NVIDIA CUDA Compiler (NVCC) supports `libc++` linkage starting with CUDA `13.4`. 
> Earlier CUDA versions must be built using Clang.

For example, to link statically against `libc++`, developer can use the following configuration
```
common --enable_platform_specific_config

build:linux --@rules_ml_toolchain//common:stdlib=libc++
build:linux --@rules_ml_toolchain//common:static_libcxx=true
```

## Configure sanitizers
For detailed instructions on how to configure and use sanitizers [click this link](sanitizers/README.md).

## Run rules_ml_toolchain tests
### CPU hermetic tests
Project supports CPU builds on:
* Linux x86_64 / aarch64
* macOS aarch64 (using LLVM 19 or newer is highly recommended, as it introduces linker updates for Apple platforms)
* Windows x86_64 (hermetic build tools paired with a non-hermetic host sysroot)

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
`bazel test //gpu/cuda/tests:all --config=build_cuda_with_clang --config=cuda --config=cuda_libraries_from_stubs`

###### Build by NVCC
`bazel test //gpu/cuda/tests:all --config=build_cuda_with_nvcc --config=cuda --config=cuda_libraries_from_stubs`

#### CUDA and non-hermetic toolchains tests
When the executor and the target are the same, a non-hermetic GPU build can still be run.

###### Build by Clang
`bazel test //gpu/cuda/tests:all --config=build_cuda_with_clang --config=cuda_clang_local --config=cuda_libraries_from_stubs`

###### Build by NVCC
`bazel test //gpu/cuda/tests:all --config=build_cuda_with_nvcc --config=cuda_clang_local --config=cuda_libraries_from_stubs`

For details, look at the `.bazelrc` file, specifically the `cuda_clang_local` configuration.

### Cross-platform builds
Project supports cross-platform builds only on Linux x86_64 executor 
and allows build for such targets:
* Linux aarch64
<!--* macOS aarch64-->

#### Build for Linux aarch64
`bazel build //cc/tests/cpu/... --platforms=//common:linux_aarch64`
<!--
#### Build for macOS aarch64
[Prepare SDK](sysroots/darwin_aarch64/README.md) before run the following command.

`bazel build //cc/tests/cpu/... --platforms=//common:macos_aarch64`
-->

## C++ toolchain features
### Clang Header Modules
To manage Clang header modules, use a producer/consumer architecture:
* **Producers:** Explicitly enable the `header_modules` feature on specific targets that are compatible with and support being compiled as header modules.
* **Consumers (Global Default):** Enable the `use_header_modules` feature globally across your workspace so that targets consume available modules by default.
* **Consumers (Opt-Out):** For specific targets that fail to build with header modules, completely disable the feature locally by adding `features = ["-use_header_modules"]` to their rule.

```starlark
# BUILD.bazel

# ---------------------------------------------------------
# 1. The producer
# ---------------------------------------------------------
cc_library(
    name = "utils_lib",
    srcs = ["utils.cc"],
    hdrs = ["utils.h"], 
    features = ["header_modules"],
    visibility = ["//visibility:public"],
)

# ---------------------------------------------------------
# 2. The consumer
# ---------------------------------------------------------
cc_library(
    name = "standard_consumer",
    srcs = ["consumer.cc"],
    deps = [":utils_lib"],
)

# ---------------------------------------------------------
# 3. The incompatible target
# ---------------------------------------------------------
cc_library(
    name = "incompatible_lib",
    srcs = ["incompatible.cc"],
    deps = [":utils_lib"],
    features = ["-use_header_modules"],
)
```

## Troubleshooting
Encountering issues? Try to find decision on [How To Fix](../HOW-TO-FIX.md) page.
