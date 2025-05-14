# Hermetic Toolchains for ML

This project provides Bazel rules to achieve hermetic and cross-platform builds.

> [!WARNING]
> This project is under active development and is not yet ready for production use.

Hermetic builds benefits:
* Reproducibility: Every build produces identical results regardless of the developer's machine environment.
* Consistency: Eliminates "works on my machine" issues, ensuring builds are consistent across different development environments.
* Isolation: Builds are isolated from the host system, minimizing unexpected dependencies and side effects.

Cross-Platform builds benefits:
* Single Source of Truth: Develop and maintain a single codebase that can be built for various target platforms (e.g., Linux, macOS).
* Efficiency: Streamlines the build and release process for multiple platforms.

# C++ toolchains 
### CPU Hermetic builds
Project supports CPU hermetic builds on:
* Linux x86_64
* macOS aarch64

You could run hermetic build tests with help of command

`bazel test //cc_toolchain/tests/cpu:all`

If project doesn't support cross-platform builds for specified platform,
it will use host utilities and host sysroot for running such build.

### GPU Hermetic builds 
Requires machine with GPU

Project supports GPU hermetic builds on:
* Linux x86_64

You could run hermetic build and test with help of command:
##### Build by Clang
`bazel test //cc_toolchain/tests/gpu:all --config=build_cuda_with_clang --config=cuda --config=cuda_libraries_from_stubs`

##### Build by NVCC
`bazel test //cc_toolchain/tests/gpu:all --config=build_cuda_with_nvcc --config=cuda --config=cuda_libraries_from_stubs`

### Non-hermetic builds
When executor and a target are the same, you still can run non-hermetic build. Command should look like:

`bazel build //cc_toolchain/tests/cpu:all --//cc_toolchain/config:enable_hermetic_cc=False`

### Cross-platform builds
Project supports cross-platform builds only on Linux x86_64 executor 
and allows build for such targets:
* Linux aarch64
* macOS aarch64

#### Build for Linux aarch64
`bazel build //cc_toolchain/tests/cpu/... --platforms=//cc_toolchain/config:linux_aarch64`

#### Build for macOS aarch64
[Prepare SDK](cc_toolchain/sysroots/macos_arm64/README.md) before run the following command.

`bazel build //cc_toolchain/tests/... --platforms=//cc_toolchain/config:macos_aarch64`
