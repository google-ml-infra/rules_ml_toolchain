# Sanitizers in rules_ml_toolchain

This project provides built-in support for LLVM sanitizer ASan for memory safety.

## ASan (Address Sanitizer)
The following configuration provides a baseline for integrating ASan into ML projects.

```
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

## ROCm Sanitizer Support

The toolchain also provides sanitizer support for ROCm builds using ROCm's hermetic LLVM toolchain.

### ROCm with ASan

```bash
bazel test --config=rocm_asan //your:test
```

Configuration:
```
common:rocm_asan --config=rocm
common:rocm_asan --features=asan
common:rocm_asan --run_under=//cc/sanitizers:sanitizer_wrapper_rocm
```

### ROCm with TSan

```bash
bazel test --config=rocm_tsan //your:test
```

Configuration:
```
common:rocm_tsan --config=rocm
common:rocm_tsan --features=tsan
common:rocm_tsan --run_under=//cc/sanitizers:sanitizer_wrapper_rocm
```

### ROCm GPU Tests with ASan

```bash
bazel test --config=rocm_asan //cc/tests/gpu:all
```

## Creating Custom Sanitizer Wrappers

The pre-configured wrappers provide basic sanitizer support with common options. Projects should create custom wrappers with project-specific suppression lists.

### Basic Wrappers (Included)

The toolchain provides basic wrappers without suppression lists:
- `//cc/sanitizers:sanitizer_wrapper_linux_x86_64`
- `//cc/sanitizers:sanitizer_wrapper_linux_aarch64`
- `//cc/sanitizers:sanitizer_wrapper_rocm`

### Creating a Custom Wrapper

```starlark
load("@rules_ml_toolchain//cc/sanitizers:sanitizer_wrapper.bzl", "sanitizer_wrapper")

sanitizer_wrapper(
    name = "my_project_sanitizer_wrapper",
    llvm_symbolizer = "@llvm_linux_x86_64//:llvm-symbolizer",
    # Add your project's suppression lists
    asan_ignore_list = "//build_tools:asan_suppressions.txt",
    lsan_ignore_list = "//build_tools:lsan_suppressions.txt",
    tsan_ignore_list = "//build_tools:tsan_suppressions.txt",
    # Customize sanitizer options
    asan_options = "detect_leaks=1:malloc_context_size=10",
    tsan_options = "halt_on_error=0",
    # Include required libraries
    additional_data = ["@llvm_linux_x86_64//:distro_libs"],
)
```

Use it in `.bazelrc`:
```
common:asan --run_under=//:my_project_sanitizer_wrapper
```

### Suppression List Format

**ASAN** (`asan_suppressions.txt`):
```
# Suppress specific functions or libraries
leak:library_name
interceptor_via_fun:function_name
```

**LSAN** (`lsan_suppressions.txt`):
```
# Suppress leak reports
leak:function_name
leak:library_name.so
```

**TSAN** (`tsan_suppressions.txt`):
```
# Suppress data race reports
race:function_name
race:library_name.so
thread:thread_function
```

See [Clang Sanitizer Documentation](https://clang.llvm.org/docs/AddressSanitizer.html#suppressing-reports) for details.

