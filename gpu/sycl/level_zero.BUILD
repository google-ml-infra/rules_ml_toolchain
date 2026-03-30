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

# Level Zero system path example:
# l0_include_dir: /usr/include/level_zero
# l0_library_dir: /usr/lib/x86_64-linux-gnu

load(
    "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl",
    "cc_toolchain_import",
)

package(
    default_visibility = [
        "//cc/impls/linux_x86_64_linux_x86_64_sycl:__pkg__",
    ],
)

filegroup(
    name = "all",
    srcs = glob([
            "include/**/*",
        ],
    ),
    visibility = ["//visibility:public"],
)

# Use level_zero symlink for includes backward compatibility (example: #include <level_zero/ze_api.h>)
cc_library(
    name = "headers",
    hdrs = glob([
        "level_zero/**/*",
    ], allow_empty = True),
    includes = [
        ".",
    ],
    visibility = ["//visibility:public"],
)
