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

package(
    default_visibility = ["//visibility:public"],
)

toolchain_type(
    name = "toolchain_type",
)

#=====================================================================
# Executor platform: Linux x86_64
#=====================================================================

# Target platform: Linux x86_64

# Essentials
toolchain(
    name = "linux_x86_64_linux_x86_64",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    target_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    toolchain = "//fortran/impls/linux_x86_64_linux_x86_64:toolchain",
    toolchain_type = ":toolchain_type",
)

# Target platform: Linux aarch64
toolchain(
    name = "linux_x86_64_linux_aarch64",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    target_compatible_with = [
        "@platforms//cpu:aarch64",
        "@platforms//os:linux",
    ],
    toolchain = "//fortran/impls/linux_x86_64_linux_aarch64:toolchain",
    toolchain_type = ":toolchain_type",
)

# Target platform: Darwin aarch64
toolchain(
    name = "linux_x86_64_darwin_aarch64",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    target_compatible_with = [
        "@platforms//cpu:aarch64",
        "@platforms//os:macos",
    ],
    toolchain = "//fortran/impls/linux_x86_64_darwin_aarch64:toolchain",
    toolchain_type = ":toolchain_type",
)

#=====================================================================
# Executor platform: aarch64
#=====================================================================

# Target platform: Linux aarch64
toolchain(
    name = "linux_aarch64_linux_aarch64",
    exec_compatible_with = [
        "@platforms//cpu:aarch64",
        "@platforms//os:linux",
    ],
    target_compatible_with = [
        "@platforms//cpu:aarch64",
        "@platforms//os:linux",
    ],
    toolchain = "//fortran/impls/linux_aarch64_linux_aarch64:toolchain",
    toolchain_type = ":toolchain_type",
)

#=====================================================================
# Executor platform: macOS aarch64
#=====================================================================

# Target platform: macOS aarch64
# buildifier: leave-alone
toolchain(
    name = "darwin_aarch64_darwin_aarch64",
    exec_compatible_with = [
        "@platforms//cpu:aarch64",
        "@platforms//os:macos",
    ],
    target_compatible_with = [
        "@platforms//cpu:aarch64",
        "@platforms//os:macos",
    ],
    toolchain = "//fortran/impls/darwin_aarch64_darwin_aarch64:toolchain",
    toolchain_type = ":toolchain_type",
)
