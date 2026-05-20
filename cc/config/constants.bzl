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

# Flags for statically linking libc++
LIBCXX_FLAGS = [
    "-lc++",
    "-lc++abi",
    "-lunwind",
]

# Flags for statically linking libstdc++
# When using -nodefaultlibs with hermetic builds, we need to explicitly
# link the C++ standard library. This list ensures all necessary libraries
# are statically linked.
# Note: libgcc, libm, libc are already provided by cc_toolchain_import from sysroot
# We only need to explicitly request static linking for libstdc++
LIBSTDCXX_FLAGS = [
    "-lstdc++",
]