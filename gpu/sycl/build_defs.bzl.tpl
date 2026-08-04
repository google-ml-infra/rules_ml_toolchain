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

load("@rules_cc//cc:defs.bzl", "cc_library")

# Macros for building SYCL code.
def if_sycl(if_true, if_false = []):
    """Shorthand for select()'ing on whether we're building with SYCL.

    Returns a select statement which evaluates to if_true if we're building
    with SYCL enabled.  Otherwise, the select statement evaluates to if_false.

    """
    return select({
        "@rules_ml_toolchain//common:is_sycl_enabled": if_true,
        "//conditions:default": if_false,
    })

def sycl_default_copts():
    """Default options for all SYCL compilations."""
    return if_sycl(["-sycl_compile"])

def sycl_default_linkopts():
    """Default options for all SYCL compilations."""
    return if_sycl(["-link_stage", "-lirc"])

def sycl_build_is_configured():
    """Returns true if SYCL compiler was enabled during the configure process."""
    return %{sycl_build_is_configured}

def if_sycl_is_configured(x):
    """Tests if the SYCL was enabled during the configure process.

    Unlike if_sycl(), this does not require that we are building with
    --config=sycl. Used to allow non-SYCL code to depend on SYCL libraries.
    """
    if %{sycl_is_configured}:
      return select({"//conditions:default": x})
    return select({"//conditions:default": []})

def if_sycl_build_is_configured(if_true, if_false = []):
    if sycl_build_is_configured():
      return if_true
    return if_false

def sycl_library(copts = [], linkopts = [], tags = [], deps = [], **kwargs):
    """Wrapper over cc_library which adds default SYCL options."""
    cc_library(copts = sycl_default_copts() + copts,
                      linkopts = sycl_default_linkopts() + linkopts,
                      tags = tags + ["gpu"],
                      deps = deps + if_sycl_is_configured([
                        "@oneapi//:headers",
                        "@level_zero//:headers",
                        "@oneapi//:libs",
                        "@zero_loader//:libze_loader",
                      ]),
                      **kwargs)
