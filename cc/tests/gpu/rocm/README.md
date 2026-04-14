# ROCm/HIP Toolchain Tests

This directory contains tests for the ROCm/HIP hermetic toolchain.

## Tests

### vector_hip_test
A simple vector addition test that verifies:
- HIP kernel compilation and execution
- HIPcc compiler integration with Bazel
- ROCm runtime functionality
- Managed memory allocation

## Running Tests Locally

To build and run the ROCm tests:

```bash
# Build all ROCm tests
bazel build \
  --config=rocm \
  --define=using_rocm=true \
  --repo_env ROCM_PATH=/opt/rocm \
  --repo_env TF_ROCM_AMDGPU_TARGETS="gfx906,gfx908,gfx90a" \
  //cc/tests/gpu/rocm:all

# Run tests (requires ROCm GPU)
bazel test \
  --config=rocm \
  --define=using_rocm=true \
  --repo_env ROCM_PATH=/opt/rocm \
  --repo_env TF_ROCM_AMDGPU_TARGETS="gfx906,gfx908,gfx90a" \
  //cc/tests/gpu/rocm:all
```

## CI/CD

Tests are automatically run in CI via `.github/workflows/rocm_linux_x86_64_linux_x86_64_build.yaml` on pull requests.

## Architecture Targets

Configure GPU architectures via environment variable:
```bash
export TF_ROCM_AMDGPU_TARGETS="gfx906,gfx908,gfx90a,gfx942"
```

Common targets:
- `gfx906`: AMD Radeon VII, MI50
- `gfx908`: MI100
- `gfx90a`: MI210, MI250, MI250X
- `gfx942`: MI300A, MI300X
