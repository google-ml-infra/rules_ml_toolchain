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

"""Repository rule for SYCL autoconfiguration.
`sycl_configure` depends on the following environment variables:
  * `TF_NEED_SYCL`: Whether to enable building with SYCL.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load(
    "//gpu/sycl:sycl_redist_versions.bzl",
    "BUILD_TEMPLATES",
    "REDIST_DICT",
)

def enable_sycl(ctx):
    """Returns whether to build with SYCL support."""
    return bool(ctx.getenv("TF_NEED_SYCL", "").strip())

# TODO: Add support of TF_ICPX_CLANG environment variable
def _use_icpx_and_clang(ctx):
    """Returns whether to use ICPX for SYCL and Clang for C++."""
    return ctx.getenv("TF_ICPX_CLANG", "").strip()

_DUMMY_CROSSTOOL_BZL_FILE = """
def error_gpu_disabled():
  fail("ERROR: Building with --config=sycl but TensorFlow is not configured " +
       "to build with GPU support. Please re-run ./configure and enter 'Y' " +
       "at the prompt to build with GPU support.")

  native.genrule(
      name = "error_gen_crosstool",
      outs = ["CROSSTOOL"],
      cmd = "echo 'Should not be run.' && exit 1",
  )

  native.filegroup(
      name = "crosstool",
      srcs = [":CROSSTOOL"],
      output_licenses = ["unencumbered"],
  )
"""

_DUMMY_CROSSTOOL_BUILD_FILE = """
load("//crosstool:error_gpu_disabled.bzl", "error_gpu_disabled")

error_gpu_disabled()
"""

def _create_dummy_repository(ctx):
    """
    Create a minimal SYCL layout that intercepts --config=sycl when SYCL
    isn't configured, emitting a clear, actionable error.
    """

    # Intercept attempts to build with --config=sycl when SYCL is not configured.
    ctx.file(
        "error_gpu_disabled.bzl",
        _DUMMY_CROSSTOOL_BZL_FILE,
    )

    ctx.file(
        "BUILD",
        _DUMMY_CROSSTOOL_BUILD_FILE,
    )

    # Materialize templated files under sycl/
    ctx.template(
        "sycl/build_defs.bzl",
        ctx.attr.build_defs_tpl,
        {
            "%{sycl_is_configured}": "False",
            "%{sycl_build_is_configured}": "False",
        },
    )

    ctx.file("sycl/BUILD", "")

def _sycl_configure_impl(ctx):
    """Implementation of the sycl_configure rule"""
    if not enable_sycl(ctx):
        _create_dummy_repository(ctx)
        return

    hermetic = ctx.getenv("SYCL_BUILD_HERMETIC") == "1"
    if not hermetic:
        fail("SYCL non-hermetic build hasn't supported")

    # Set up BUILD file for sycl/
    ctx.template(
        "sycl/build_defs.bzl",
        ctx.attr.build_defs_tpl,
        {
            "%{sycl_is_configured}": "True",
            "%{sycl_build_is_configured}": "True",
        },
    )

    ctx.file("sycl/BUILD", ctx.read(ctx.attr.build_defs_tpl))

    ctx.file("BUILD", "")

sycl_configure = repository_rule(
    implementation = _sycl_configure_impl,
    local = True,
    attrs = {
        "build_defs_tpl": attr.label(default = Label("//gpu/sycl:build_defs.bzl.tpl")),
        "build_file": attr.label(default = Label("//gpu/sycl:sycl.BUILD")),
    },
)
