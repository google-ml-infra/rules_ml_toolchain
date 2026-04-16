# Copyright 2025 The OpenXLA Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================

"""ROCm HIPcc feature rule for feature-based toolchain configuration.

This rule creates a toolchain feature that sets environment variables and
compiler flags needed for ROCm/HIP compilation. It follows the same pattern
as cuda_nvcc_feature.bzl in rules_ml_toolchain.
"""

load(
    "@rules_cc//cc:action_names.bzl",
    "ACTION_NAMES",
    "ALL_CC_COMPILE_ACTION_NAMES",
    "ALL_CPP_COMPILE_ACTION_NAMES",
    "CC_LINK_EXECUTABLE_ACTION_NAMES",
    "DYNAMIC_LIBRARY_LINK_ACTION_NAMES",
)
load(
    "@rules_cc//cc:cc_toolchain_config_lib.bzl",
    "FeatureInfo",
    "env_entry",
    "env_set",
    "flag_group",
    "flag_set",
    _feature = "feature",
)

# All actions that need environment variables set
ALL_ACTIONS = [
    ACTION_NAMES.c_compile,
    ACTION_NAMES.cpp_compile,
    ACTION_NAMES.linkstamp_compile,
    ACTION_NAMES.cc_flags_make_variable,
    ACTION_NAMES.cpp_module_codegen,
    ACTION_NAMES.cpp_header_parsing,
    ACTION_NAMES.cpp_module_compile,
    ACTION_NAMES.assemble,
    ACTION_NAMES.preprocess_assemble,
    ACTION_NAMES.lto_indexing,
    ACTION_NAMES.lto_backend,
    ACTION_NAMES.lto_index_for_executable,
    ACTION_NAMES.lto_index_for_dynamic_library,
    ACTION_NAMES.lto_index_for_nodeps_dynamic_library,
    ACTION_NAMES.cpp_link_executable,
    ACTION_NAMES.cpp_link_dynamic_library,
    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
    ACTION_NAMES.cpp_link_static_library,
    ACTION_NAMES.clif_match,
]

def _rocm_hipcc_feature_impl(ctx):
    """Implementation of the rocm_hipcc_feature rule.

    Sets up environment variables and compiler flags for ROCm/HIP compilation.
    The environment variables are read by the hipcc_wrapper script to locate
    the HIPcc compiler and ROCm toolkit.
    """
    # Construct full paths using workspace_root from the rocm_toolkit label
    # and relative paths from hipcc_config() struct
    workspace_root = ctx.attr.rocm_toolkit.label.workspace_root
    package = ctx.attr.rocm_toolkit.label.package

    # Combine workspace path with relative paths from the struct
    rocm_path = workspace_root + "/" + package + "/" + ctx.attr.rocm_path
    hipcc_path = workspace_root + "/" + package + "/" + ctx.attr.hipcc_path

    # Build cuda_wrappers_path if provided
    cuda_wrappers_path = ""
    if ctx.attr.cuda_wrappers_path:
        cuda_wrappers_path = workspace_root + "/" + package + "/" + ctx.attr.cuda_wrappers_path

    # Build environment entries
    # Note: GCC_PATH is set by cc_toolchain_config's __tool_paths_as_environment_vars
    # feature based on the c_compiler attribute, so we don't set it here to avoid
    # duplicate environment variable errors.
    env_entries = [
        env_entry("HIPCC_PATH", hipcc_path),
        env_entry("ROCM_PATH", rocm_path),
        env_entry("HIPCC_VERSION", ctx.attr.version),
        env_entry("ROCM_CLANG_VERSION", ctx.attr.clang_version),
    ]

    # Add CUDA_WRAPPERS_PATH if available
    if cuda_wrappers_path:
        env_entries.append(env_entry("CUDA_WRAPPERS_PATH", cuda_wrappers_path))

    # Build compiler flags (common to both C and C++)
    common_compiler_flags = []

    # Add --rocm-path flag pointing to the ROCm toolkit
    common_compiler_flags.append("--rocm-path=" + rocm_path)

    # Add architecture flags if specified
    for arch in ctx.attr.amdgpu_targets:
        common_compiler_flags.append("--offload-arch=" + arch)

    # ROCm-specific compilation flags (common to C and C++)
    common_compiler_flags.extend([
        # Disable relocatable device code for faster compilation
        "-fno-gpu-rdc",
        # Flush denormals to zero on GPU
        "-fcuda-flush-denormals-to-zero",
    ])

    # C++ only flags
    cpp_only_flags = [
        # Force C++17 for HIP compilation (only valid for C++)
        "--std=c++17",
    ]

    return _feature(
        name = ctx.label.name,
        enabled = ctx.attr.enabled,
        provides = ctx.attr.provides,
        flag_sets = [
            # Common flags for all compile and link actions
            flag_set(
                actions = CC_LINK_EXECUTABLE_ACTION_NAMES +
                          DYNAMIC_LIBRARY_LINK_ACTION_NAMES +
                          ALL_CC_COMPILE_ACTION_NAMES,
                flag_groups = [
                    flag_group(
                        flags = common_compiler_flags,
                    ),
                ] if common_compiler_flags else [],
            ),
            # C++ only flags (not applied to c_compile)
            flag_set(
                actions = ALL_CPP_COMPILE_ACTION_NAMES,
                flag_groups = [
                    flag_group(
                        flags = cpp_only_flags,
                    ),
                ],
            ),
        ],
        env_sets = [env_set(
            actions = ALL_ACTIONS,
            env_entries = env_entries,
        )],
    )

rocm_hipcc_feature = rule(
    implementation = _rocm_hipcc_feature_impl,
    attrs = {
        "enabled": attr.bool(
            default = True,
            doc = "Whether this feature is enabled by default.",
        ),
        "provides": attr.string_list(
            doc = "Features that this feature provides (for mutual exclusion).",
        ),
        "rocm_toolkit": attr.label(
            mandatory = True,
            doc = "Label pointing to the ROCm toolkit (for dependencies).",
        ),
        "host_compiler": attr.label(
            allow_single_file = True,
            doc = "Label pointing to the host compiler (clang).",
        ),
        "version": attr.string(
            mandatory = True,
            doc = "The ROCm/HIP version string.",
        ),
        "amdgpu_targets": attr.string_list(
            default = [],
            doc = "List of AMDGPU targets (e.g., gfx906, gfx908).",
        ),
        "rocm_path": attr.string(
            mandatory = True,
            doc = "Path to the ROCm installation directory.",
        ),
        "hipcc_path": attr.string(
            mandatory = True,
            doc = "Path to the hipcc compiler binary.",
        ),
        "clang_version": attr.string(
            default = "",
            doc = "The clang version in ROCm's LLVM (e.g., '22', '21').",
        ),
        "cuda_wrappers_path": attr.string(
            default = "",
            doc = "Path to ROCm's cuda_wrappers headers (relative to ROCm root).",
        ),
    },
    provides = [FeatureInfo],
    doc = """
Creates a toolchain feature for ROCm/HIP compilation.

This feature sets environment variables (HIPCC_PATH, ROCM_PATH, HIPCC_VERSION,
ROCM_CLANG_VERSION, CUDA_WRAPPERS_PATH, GCC_PATH) that are read by the hipcc_wrapper script,
and adds compiler flags for ROCm compilation (--rocm-path, --offload-arch).

Example usage:
    rocm_hipcc_feature(
        name = "rocm_hipcc_feature",
        rocm_toolkit = "@config_rocm_hipcc//rocm:rocm_root",
        host_compiler = "@llvm_linux_x86_64//:clang",
        version = "6.0",
        amdgpu_targets = ["gfx906", "gfx908"],
        rocm_path = "external/_main~hipcc_configure_ext~config_rocm_hipcc/rocm/rocm_dist",
        hipcc_path = "external/_main~hipcc_configure_ext~config_rocm_hipcc/rocm/rocm_dist/bin/hipcc",
    )
""",
)
