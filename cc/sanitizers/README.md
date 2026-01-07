# Sanitizers in rules_ml_toolchain

This project provides built-in support for LLVM sanitizer ASan for memory safety.

## ASan (Address Sanitizer)
The following configuration provides a baseline for integrating ASan into ML projects.

```
# A separate toolchain configuration is provided to support sanitizer (ASan)
common:asan --platforms=@rules_ml_toolchain//common:linux_x86_64_with_sanitizers
common:asan --@rules_ml_toolchain//common:sanitize=address
# By default, the AddressSanitizer (ASan) runtime is split: libclang_rt.asan_static.a is linked into all binaries,
# while libclang_rt.asan.a is reserved exclusively for executables. However, this standard linking logic fails
# for shared libraries used within a py_binary environment. Such libraries require the full set of ASan symbols
# to be present within the library itself to function correctly when loaded by the Python interpreter.
# Set the following parameter to True if all set of all symbols should be added to dynamic library.
common:asan --@rules_ml_toolchain//common:asan_dynamic_lib_as_executable=False
common:asan --strip=never
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


