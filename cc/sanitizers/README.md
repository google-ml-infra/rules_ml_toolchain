# Sanitizers in rules_ml_toolchain

This project provides built-in support for LLVM sanitizer ASan for memory safety.

## ASan (Address Sanitizer)
The following configuration provides a baseline for integrating ASan into ML projects.

```
# A separate toolchain configuration is provided to support sanitizer
common:asan --platforms=@rules_ml_toolchain//common:linux_x86_64_with_sanitizers
# Specify the desired sanitizer type; currently, only AddressSanitizer (ASAN) is supported
common:asan --@rules_ml_toolchain//common:sanitize=address
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


