# Hermetic Toolchains for ML

> [!WARNING]
> This project is under active development and is not yet ready for production use.

This project provides Bazel rules for ML project to achieve hermetic and cross-platform builds.

C++ and CUDA hermetic builds benefits:
* Reproducibility: Every build produces identical results regardless of the developer's machine environment.
* Consistency: Eliminates "works on my machine" issues, ensuring builds are consistent across different development environments.
* Isolation: Builds are isolated from the host system, minimizing unexpected dependencies and side effects.

C++ cross-platform builds benefits:
* Single Source of Truth: Develop and maintain a single codebase that can be built for various target platforms (e.g., Linux, macOS).
* Efficiency: Streamlines the build and release process for multiple platforms.

# Configure C++ toolchains

### How to configure toolchains for ML project

Add below code before CUDA initialization in WORKSPACE file

```
http_archive(
    name = "rules_ml_toolchain",
    sha256 = "562e0517f4e833afe0de7bb8da49f9adafcbca30a8259f118a65b4adf533b51f",
    strip_prefix = "rules_ml_toolchain-4995c0be587c6e173fe8cf8dc614f92011f7913d",
    urls = [
        "https://github.com/google-ml-infra/rules_ml_toolchain/archive/4995c0be587c6e173fe8cf8dc614f92011f7913d.zip",
    ],
)

load(
    "@rules_ml_toolchain//cc/deps:cc_toolchain_deps.bzl",
    "cc_toolchain_deps",
)

cc_toolchain_deps()

register_toolchains("@rules_ml_toolchain//cc:linux_x86_64_linux_x86_64")
register_toolchains("@rules_ml_toolchain//cc:linux_x86_64_linux_x86_64_cuda")

```

It must be ensured that builds for Linux x86_64 are run without the `--noincompatible_enable_cc_toolchain_resolution` 
flag. Furthermore, reliance on environment variables like `CLANG_COMPILER_PATH`, `BAZEL_COMPILER`, `CC`, or `CXX` 
must be avoided.

For diagnosing the utility set being used during build or test execution, the `--subcommands` flag should be appended 
to the Bazel command. This will facilitate checking that the compiler or linker are not being used from your machine.

## How to run this project tests
### CPU Hermetic tests
Project supports CPU hermetic builds on:
* Linux x86_64
* macOS aarch64

The command allows you to run hermetic build tests:

`bazel test //cc/tests/cpu:all`

If project doesn't support cross-platform builds for specified platform,
it will use host utilities and host sysroot for running such build.

##### Non-hermetic CPU builds
When executor and a target are the same, you still can run non-hermetic build. Command should look like:

`bazel build //cc/tests/cpu:all --config=clang_local`

For details, look at the `.bazelrc` file, specifically the `clang_local` configuration.

### GPU Hermetic tests
Project supports GPU hermetic builds on Linux x86_64 and requires machine with NVIDIA GPU

You could run hermetic tests with help of command:
###### Build by Clang
`bazel test //cc/tests/gpu:all --config=build_cuda_with_clang --config=cuda --config=cuda_libraries_from_stubs`

###### Build by NVCC
`bazel test //cc/tests/gpu:all --config=build_cuda_with_nvcc --config=cuda --config=cuda_libraries_from_stubs`

#### Non-hermetic GPU tests
When executor and a target are the same, you still can run non-hermetic GPU build.

###### Build by Clang
`bazel test //cc/tests/gpu:all --config=build_cuda_with_clang --config=cuda_clang_local --config=cuda_libraries_from_stubs`

###### Build by NVCC
`bazel test //cc/tests/gpu:all --config=build_cuda_with_nvcc --config=cuda_clang_local --config=cuda_libraries_from_stubs`

For details, look at the `.bazelrc` file, specifically the `cuda_clang_local` configuration.

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
