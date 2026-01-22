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
            "lib/**/*",
        ],
    ),
    visibility = ["//visibility:public"],
)

# TODO: Make libraries version insensitive
cc_toolchain_import(
    name = "libs",
    additional_libs = glob([
        "**/*",
    ]),
    shared_library = "libze_loader.so",
    visibility = ["//visibility:public"],
)

cc_library(
    name = "libze_loader",
    srcs = glob([
        "lib/libze_loader.so*",
        "lib/liblevel_zero_utils.a",
        "lib/libze_null.so*",
        "lib/libze_tracing_layer.so*",
    ]),
    data = ([
        "lib/libze_loader.so.1",
    ]),
    linkstatic = 1,
    visibility = ["//visibility:public"],
)
