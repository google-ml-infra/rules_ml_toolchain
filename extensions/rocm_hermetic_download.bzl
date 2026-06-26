# Copyright 2026 Google LLC
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

"""Module extension for ROCm hermetic download (for testing purposes only)."""

load(
    "//gpu/rocm:rocm_hermetic_download.bzl",
    "ROCM_SHA256",
    "ROCM_URL",
    "rocm_hermetic_download",
)

def _rocm_hermetic_download_ext_impl(mctx):
    """Implementation of the rocm_hermetic_download_ext module extension."""
    # Download the ROCm distribution for testing (URL and SHA256 from rocm_hermetic_download.bzl)
    rocm_hermetic_download(
        name = "rocm_hermetic_dist",
        url = ROCM_URL,
        sha256 = ROCM_SHA256,
    )

rocm_hermetic_download_ext = module_extension(
    implementation = _rocm_hermetic_download_ext_impl,
    doc = """ROCm hermetic download module extension for testing.

This extension downloads a hardcoded ROCm distribution for testing purposes only.
For production use, consumers should provide their own ROCm installation.

Usage in MODULE.bazel:

```starlark
rocm_hermetic = use_extension("@rules_ml_toolchain//extensions:rocm_hermetic_download.bzl", "rocm_hermetic_download_ext")
use_repo(rocm_hermetic, "rocm_hermetic_dist")
```
""",
)
