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

"""HIPcc module extension for ROCm toolchain configuration."""

load(
    "//gpu/rocm:hipcc_configure.bzl",
    "hipcc_configure",
)

def _hipcc_configure_ext_impl(mctx):
    """Implementation of the hipcc_configure_ext module extension."""
    # Collect rocm_dist from tags (last one wins)
    rocm_dist = None
    for mod in mctx.modules:
        for tag in mod.tags.configure:
            if tag.rocm_dist:
                rocm_dist = tag.rocm_dist

    # rocm_dist is mandatory
    if not rocm_dist:
        fail("rocm_dist is required. Use hipcc_configure.configure(rocm_dist = ...) in MODULE.bazel")

    # Create hipcc_configure with the provided rocm_dist
    hipcc_configure(
        name = "config_rocm_hipcc",
        rocm_dist = rocm_dist,
    )

_configure_tag = tag_class(
    attrs = {
        "rocm_dist": attr.label(
            mandatory = True,
            doc = "Label to the ROCm distribution (e.g., @rocm_hermetic_dist//:rocm_root or @local_config_rocm//:rocm_root)",
        ),
    },
)

hipcc_configure_ext = module_extension(
    implementation = _hipcc_configure_ext_impl,
    tag_classes = {"configure": _configure_tag},
    doc = """HIPcc module extension for configuring the ROCm toolchain.

Usage in MODULE.bazel:

```starlark
# rules_ml_toolchain tests (uses rocm_hermetic_download):
hipcc_configure = use_extension("@rules_ml_toolchain//extensions:hipcc_configure.bzl", "hipcc_configure_ext")
hipcc_configure.configure(rocm_dist = "@rocm_hermetic_dist//:rocm_root")
use_repo(hipcc_configure, "config_rocm_hipcc")

# XLA (uses local_config_rocm):
hipcc_configure = use_extension("@rules_ml_toolchain//extensions:hipcc_configure.bzl", "hipcc_configure_ext")
hipcc_configure.configure(rocm_dist = "@local_config_rocm//:rocm_root")
use_repo(hipcc_configure, "config_rocm_hipcc")
```
""",
)
