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

"""Extension for global_symbol_version_configure repository rule (bzlmod support)."""

load(
    "//cc/rocm/features:global_symbol_version_configure.bzl",
    "GLOBAL_SYMBOLS_TO_VERSION",
    "global_symbol_version_configure",
)

def _global_symbol_version_ext_impl(_module_ctx):
    """Extension implementation for global_symbol_version_configure.

    Args:
        _module_ctx: The module extension context.
    """

    # The symbols to version are read from the environment by the repository
    # rule itself, so the extension only has to create the repository.
    global_symbol_version_configure(name = "global_symbol_version_config")

global_symbol_version_ext = module_extension(
    implementation = _global_symbol_version_ext_impl,
    environ = [GLOBAL_SYMBOLS_TO_VERSION],
    doc = """Generates the global symbol version script from the environment.

Usage in MODULE.bazel:

```starlark
global_symbol_version = use_extension("@rules_ml_toolchain//extensions:global_symbol_version_configure.bzl", "global_symbol_version_ext")
use_repo(global_symbol_version, "global_symbol_version_config")
```
""",
)
