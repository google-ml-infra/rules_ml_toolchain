# Copyright 2025 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Module extension for toolchain."""

load("//cc/deps:cc_toolchain_deps.bzl", "cc_toolchain_deps")

def _toolchain_module_ext_impl(mctx):
    cc_toolchain_deps()

toolchain_ext = module_extension(
    implementation = _toolchain_module_ext_impl,
)
