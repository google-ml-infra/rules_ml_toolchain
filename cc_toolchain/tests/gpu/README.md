## Build CUDA binary
### by Clang

`bazel build --config=cuda --config=build_cuda_with_clang //cc_toolchain/tests/gpu:vector_cuda_test`

### by NVCC 

`bazel build --config=cuda --config=build_cuda_with_nvcc //cc_toolchain/tests/gpu:vector_cuda_test`

## Test CUDA (GPU machine only)
### by Clang

`bazel test --config=cuda --config=build_cuda_with_clang //cc_toolchain/tests/gpu:vector_cuda_test`

### by NVCC (TASK IN PROGRESS)

`bazel test --config=cuda --config=build_cuda_with_nvcc //cc_toolchain/tests/gpu:vector_cuda_test`

## Clang non hermetic builds
bazel build //third_party/gpus/tests:vector_cuda -s \
    --action_env=CCC_OVERRIDE_OPTIONS="^--gcc-install-dir=/usr/lib/gcc/x86_64-linux-gnu/13" \
    --action_env=CLANG_COMPILER_PATH=/usr/lib/llvm-17/bin/clang \
    --config=build_cuda_with_clang \
    --config=cuda \
    --config=cuda_libraries_from_stubs \
    --host_linkopt=-lrt \
    --linkopt=-lrt \
    --repo_env=CC=/usr/lib/llvm-17/bin/clang \
    --repo_env=CXX=/usr/lib/llvm-17/bin/clang++

## NVCC non hermetic builds
bazel build //third_party/gpus/tests:vector_cuda -s \
--action_env=CCC_OVERRIDE_OPTIONS="^--gcc-install-dir=/usr/lib/gcc/x86_64-linux-gnu/13" \
--action_env=CLANG_COMPILER_PATH=/usr/lib/llvm-17/bin/clang \
--config=build_cuda_with_clang \
--config=cuda \
--config=cuda_libraries_from_stubs \
--host_linkopt=-lrt \
--linkopt=-lrt \
--repo_env=CC=/usr/lib/llvm-17/bin/clang \
--repo_env=CXX=/usr/lib/llvm-17/bin/clang++
