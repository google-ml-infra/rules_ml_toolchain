# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================

"""HIPcc module extension for ROCm toolchain configuration."""

load(
    "//gpu/rocm:hipcc_configure.bzl",
    "hipcc_configure",
)

def _hipcc_configure_ext_impl(mctx):
    """Implementation of the hipcc_configure_ext module extension."""
    hipcc_configure(name = "config_rocm_hipcc")

hipcc_configure_ext = module_extension(
    implementation = _hipcc_configure_ext_impl,
    doc = """HIPcc module extension for configuring the ROCm toolchain.

Usage in MODULE.bazel:

```starlark
hipcc_configure = use_extension("@rules_ml_toolchain//extensions:hipcc_configure.bzl", "hipcc_configure_ext")
use_repo(hipcc_configure, "config_rocm_hipcc")
```
""",
)
