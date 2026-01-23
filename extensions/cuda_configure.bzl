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

"""CUDA module extension."""

load(
    "//gpu/cuda:cuda_configure.bzl",
    "cuda_configure",
)

def _cuda_configure_ext_impl(mctx):
    """Implementation of the cuda_configure_ext module extension."""
    # Collect configure tag attributes from all modules.
    # Later modules override earlier ones for each attribute.
    kwargs = {}

    for mod in mctx.modules:
        for tag in mod.tags.configure:
            # environ (string_dict)
            if tag.environ:
                kwargs["environ"] = tag.environ

            # Version labels
            if tag.cccl_version:
                kwargs["cccl_version"] = tag.cccl_version
            if tag.crt_version:
                kwargs["crt_version"] = tag.crt_version
            if tag.cublas_version:
                kwargs["cublas_version"] = tag.cublas_version
            if tag.cudart_version:
                kwargs["cudart_version"] = tag.cudart_version
            if tag.cudnn_version:
                kwargs["cudnn_version"] = tag.cudnn_version
            if tag.cufft_version:
                kwargs["cufft_version"] = tag.cufft_version
            if tag.cupti_version:
                kwargs["cupti_version"] = tag.cupti_version
            if tag.curand_version:
                kwargs["curand_version"] = tag.curand_version
            if tag.cusolver_version:
                kwargs["cusolver_version"] = tag.cusolver_version
            if tag.cusparse_version:
                kwargs["cusparse_version"] = tag.cusparse_version
            if tag.nvcc_binary:
                kwargs["nvcc_binary"] = tag.nvcc_binary
            if tag.nvcc_version:
                kwargs["nvcc_version"] = tag.nvcc_version
            if tag.nvjitlink_version:
                kwargs["nvjitlink_version"] = tag.nvjitlink_version
            if tag.nvml_version:
                kwargs["nvml_version"] = tag.nvml_version
            if tag.nvtx_version:
                kwargs["nvtx_version"] = tag.nvtx_version
            if tag.nvvm_version:
                kwargs["nvvm_version"] = tag.nvvm_version

            # Build/config file templates
            if tag.local_config_cuda_build_file:
                kwargs["local_config_cuda_build_file"] = tag.local_config_cuda_build_file
            if tag.build_defs_tpl:
                kwargs["build_defs_tpl"] = tag.build_defs_tpl
            if tag.cuda_build_tpl:
                kwargs["cuda_build_tpl"] = tag.cuda_build_tpl
            if tag.cuda_config_tpl:
                kwargs["cuda_config_tpl"] = tag.cuda_config_tpl
            if tag.cuda_config_py_tpl:
                kwargs["cuda_config_py_tpl"] = tag.cuda_config_py_tpl

            # Crosstool templates
            if tag.crosstool_wrapper_driver_is_not_gcc_tpl:
                kwargs["crosstool_wrapper_driver_is_not_gcc_tpl"] = tag.crosstool_wrapper_driver_is_not_gcc_tpl
            if tag.crosstool_build_tpl:
                kwargs["crosstool_build_tpl"] = tag.crosstool_build_tpl
            if tag.cc_toolchain_config_tpl:
                kwargs["cc_toolchain_config_tpl"] = tag.cc_toolchain_config_tpl

    cuda_configure(name = "local_config_cuda", **kwargs)

_configure_tag = tag_class(
    attrs = {
        # Environment variables dict
        "environ": attr.string_dict(
            doc = "Environment variables to set during CUDA configuration.",
        ),
        # Version labels for CUDA components
        "cccl_version": attr.label(
            allow_single_file = True,
            doc = "Label pointing to the CCCL version.bzl file.",
        ),
        "crt_version": attr.label(
            allow_single_file = True,
            doc = "Label pointing to the CRT version.bzl file.",
        ),
        "cublas_version": attr.label(
            allow_single_file = True,
            doc = "Label pointing to the cuBLAS version.bzl file.",
        ),
        "cudart_version": attr.label(
            allow_single_file = True,
            doc = "Label pointing to the CUDA runtime version.bzl file.",
        ),
        "cudnn_version": attr.label(
            allow_single_file = True,
            doc = "Label pointing to the cuDNN version.bzl file.",
        ),
        "cufft_version": attr.label(
            allow_single_file = True,
            doc = "Label pointing to the cuFFT version.bzl file.",
        ),
        "cupti_version": attr.label(
            allow_single_file = True,
            doc = "Label pointing to the CUPTI version.bzl file.",
        ),
        "curand_version": attr.label(
            allow_single_file = True,
            doc = "Label pointing to the cuRAND version.bzl file.",
        ),
        "cusolver_version": attr.label(
            allow_single_file = True,
            doc = "Label pointing to the cuSOLVER version.bzl file.",
        ),
        "cusparse_version": attr.label(
            allow_single_file = True,
            doc = "Label pointing to the cuSPARSE version.bzl file.",
        ),
        "nvcc_binary": attr.label(
            allow_single_file = True,
            doc = "Label pointing to the nvcc binary.",
        ),
        "nvcc_version": attr.label(
            allow_single_file = True,
            doc = "Label pointing to the nvcc version.bzl file.",
        ),
        "nvjitlink_version": attr.label(
            allow_single_file = True,
            doc = "Label pointing to the nvjitlink version.bzl file.",
        ),
        "nvml_version": attr.label(
            allow_single_file = True,
            doc = "Label pointing to the NVML version.bzl file.",
        ),
        "nvtx_version": attr.label(
            allow_single_file = True,
            doc = "Label pointing to the NVTX version.bzl file.",
        ),
        "nvvm_version": attr.label(
            allow_single_file = True,
            doc = "Label pointing to the NVVM version.bzl file.",
        ),
        # Build and config file templates
        "local_config_cuda_build_file": attr.label(
            allow_single_file = True,
            doc = "Label pointing to the local_config_cuda BUILD file.",
        ),
        "build_defs_tpl": attr.label(
            allow_single_file = True,
            doc = "Label pointing to the build_defs.bzl template.",
        ),
        "cuda_build_tpl": attr.label(
            allow_single_file = True,
            doc = "Label pointing to the cuda BUILD template.",
        ),
        "cuda_config_tpl": attr.label(
            allow_single_file = True,
            doc = "Label pointing to the cuda_config.h template.",
        ),
        "cuda_config_py_tpl": attr.label(
            allow_single_file = True,
            doc = "Label pointing to the cuda_config.py template.",
        ),
        # Crosstool templates
        "crosstool_wrapper_driver_is_not_gcc_tpl": attr.label(
            allow_single_file = True,
            doc = "Label pointing to the crosstool wrapper driver template.",
        ),
        "crosstool_build_tpl": attr.label(
            allow_single_file = True,
            doc = "Label pointing to the crosstool BUILD template.",
        ),
        "cc_toolchain_config_tpl": attr.label(
            allow_single_file = True,
            doc = "Label pointing to the cc_toolchain_config.bzl template.",
        ),
    },
    doc = "Configure the CUDA toolchain with custom settings.",
)

cuda_configure_ext = module_extension(
    implementation = _cuda_configure_ext_impl,
    tag_classes = {"configure": _configure_tag},
    doc = """CUDA module extension for configuring the hermetic CUDA toolchain.

Usage in MODULE.bazel:

```starlark
cuda = use_extension("//extensions:cuda_configure.bzl", "cuda_configure_ext")

# Optional: Override specific configuration settings
cuda.configure(
    crosstool_wrapper_driver_is_not_gcc_tpl = "@my_project//:my_wrapper.tpl",
)

use_repo(cuda, "local_config_cuda")
```
""",
)
