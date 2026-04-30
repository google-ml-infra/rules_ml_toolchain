#!/usr/bin/env bash

bazel test \
  --@rules_ml_toolchain//cc/sysroots:use_local_sysroot=True \
  --config=rocm \
  --repo_env=TF_ROCM_AMDGPU_TARGETS="gfx942" \
  --repo_env=ROCM_DISTRO_VERSION="rocm_7.12.0_gfx94X" \
  --config=bzlmod \
  --define=using_rocm=true \
  //cc/tests/gpu/rocm:all
