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

"""ROCm module extension."""

load(
    "//gpu/rocm:rocm_configure.bzl",
    "rocm_configure",
)

def _rocm_configure_ext_impl(mctx):
    """Implementation of the rocm_configure_ext module extension."""
    rocm_configure(name = "local_config_rocm")

rocm_configure_ext = module_extension(
    implementation = _rocm_configure_ext_impl,
    doc = """ROCm module extension for configuring the ROCm toolchain.

Usage in MODULE.bazel:

```starlark
rocm_configure = use_extension("@rules_ml_toolchain//extensions:rocm_configure.bzl", "rocm_configure_ext")
use_repo(rocm_configure, "local_config_rocm")
```
""",
)
