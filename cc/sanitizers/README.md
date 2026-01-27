# Sanitizers in rules_ml_toolchain

This project provides built-in support for LLVM sanitizer ASan for memory safety.

## ASan (Address Sanitizer)
The following configuration provides a baseline for integrating ASan into ML projects.

```
# A separate toolchain configuration is provided to support sanitizer
common:asan --platforms=@rules_ml_toolchain//common:linux_x86_64_with_sanitizers
# Enable ASan (AddressSanitizer) feature
common:asan --features=asan
```

### Tests for verifying AddressSanitizer (ASan) functionality
```
bazel test --test_tag_filters=-noasan \
    --config=asan \
    //cc/sanitizers/tests:all
```

### How to run all CPU tests with enabled ASan
```
bazel test --test_tag_filters=-noasan \
    --config=asan \
    //cc/tests/cpu:all
```

### How to run all GPU tests with enabled ASan

```
bazel test --test_tag_filters=-noasan \
    --config=asan \
    --config=build_cuda_with_clang \
    --config=cuda \
    --config=cuda_libraries_from_stubs \
    //cc/tests/gpu:all
```

```
bazel test --test_tag_filters=-noasan \
    --config=asan \
    --config=build_cuda_with_nvcc \
    --config=cuda \
    --config=cuda_libraries_from_stubs \
    //cc/tests/gpu:all
```
## Troubleshooting

### Linker error `undefined symbol: __asan_*`

This error means you have compiled your C++ code with AddressSanitizer (ASAN) enabled, 
but the linker cannot find the necessary ASAN runtime libraries when trying to load the module.

#### Why this happens
When you compile with -fsanitize=address, the compiler inserts calls to special functions 
like `__asan_option_detect_stack_use_after_return` or other. These functions live in the ASAN 
runtime library (libasan).

In a standard executable, the linker pulls these in automatically. However, a pybind11 module 
is a shared object (.so).

#### How to Fix It

To resolve this error when using ASAN with a Bazel `cc_binary(linkshared = True)` (used as pybind11 extension), 
you should modify your build target to include `asan_runtime_closure` feature.
Please see the following example:

```
cc_binary(
    name = "pybind_extension",
    srcs = [...],
    linkshared = True,
    deps = [
        "@pybind11",
    ],
    features = ["asan_runtime_closure"],
)
```

