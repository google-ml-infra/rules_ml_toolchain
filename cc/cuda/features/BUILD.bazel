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

load(
    "//third_party/rules_cc_toolchain/features:features.bzl",
    "cc_feature",
    "cc_toolchain_import_feature",
    "cc_toolchain_sysroot_feature",
)

package(
    default_visibility = ["//cc/impls/cuda:__pkg__"],
)

cc_feature(
    name = "warnings",
    compiler_flags = [
        "-fcolor-diagnostics",
    ],
    enabled = True,
)

# Hermetic CUDA includes.
cc_feature(
    name = "hermetic",
    compiler_flags = ["-nocudainc"],
    enabled = True,
)

# '-x cuda' adds by cuda_library, couldn't be added hear because it brokes other non cuda_library target
#cc_feature(
#    name = "language",
#    cc_flags = [
#        "-x cuda",
#    ],
#    enabled = True,
#)
