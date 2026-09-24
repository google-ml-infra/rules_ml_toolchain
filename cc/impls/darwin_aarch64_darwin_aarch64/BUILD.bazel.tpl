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

# ==============================================================================
# Tools: macOS aarch64, Sysroot: macOS aarch64
# ==============================================================================

load("@rules_ml_toolchain//cc/impls/darwin_aarch64_darwin_aarch64:toolchain.bzl", "darwin_aarch64_darwin_aarch64_toolchain")

package(
    default_visibility = [
        "//visibility:public",
    ],
)

darwin_aarch64_darwin_aarch64_toolchain(
    name = "toolchain",
    sysroot = "%{SYSROOT}",
)
