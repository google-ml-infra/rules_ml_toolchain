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

"""Public Starlark rules and providers for building Fortran targets."""

load(
    "//fortran:toolchain.bzl",
    _FortranToolchainInfo = "FortranToolchainInfo",
    _fortran_toolchain = "fortran_toolchain",
)
load(
    "//third_party/rules_fortran:defs.bzl",
    _FortranInfo = "FortranInfo",
    _fortran_binary = "fortran_binary",
    _fortran_library = "fortran_library",
    _fortran_test = "fortran_test",
)

# Public rules
fortran_binary = _fortran_binary
fortran_library = _fortran_library
fortran_test = _fortran_test
fortran_toolchain = _fortran_toolchain

# Public providers
FortranInfo = _FortranInfo
FortranToolchainInfo = _FortranToolchainInfo
