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

"""Module extension for local sysroot configuration."""

load("//cc/sysroots:local_sysroot.bzl", "local_sysroot")

def _local_sysroot_configure_ext_impl(mctx):
    """Implementation of the local_sysroot_configure_ext module extension."""

    # Create local sysroot repositories for common platforms
    # These always exist so they can be referenced in select() statements
    local_sysroot(name = "local_sysroot_linux_x86_64")
    local_sysroot(name = "local_sysroot_linux_aarch64")

    return mctx.extension_metadata(
        reproducible = True,
    )

local_sysroot_configure_ext = module_extension(
    implementation = _local_sysroot_configure_ext_impl,
    doc = """Local sysroot module extension for non-hermetic builds.

Usage in MODULE.bazel:

```starlark
local_sysroot_configure = use_extension(
    "@rules_ml_toolchain//extensions:local_sysroot_configure.bzl",
    "local_sysroot_configure_ext"
)
use_repo(local_sysroot_configure, "local_sysroot_linux_x86_64")
```
""",
)
