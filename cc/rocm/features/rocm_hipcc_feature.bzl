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

"""ROCm HIPcc feature for toolchain configuration."""

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
    """Implementation of the rocm_hipcc_feature rule."""

    # Construct paths from the rocm_toolkit label
    workspace_root = ctx.attr.rocm_toolkit.label.workspace_root
    package = ctx.attr.rocm_toolkit.label.package

    # Combine workspace path with relative paths
    rocm_path = workspace_root + "/" + package + "/" + ctx.attr.rocm_path
    hipcc_path = workspace_root + "/" + package + "/" + ctx.attr.hipcc_path

    # Environment variables
    env_entries = [
        env_entry("HIPCC_PATH", hipcc_path),
        env_entry("ROCM_PATH", rocm_path),
        env_entry("HIPCC_VERSION", ctx.attr.version),
        env_entry("ROCM_CLANG_VERSION", ctx.attr.clang_version),
    ]

    # Compiler flags
    common_compiler_flags = []

    # Add --rocm-path flag
    common_compiler_flags.append("--rocm-path=" + rocm_path)

    # Add ROCm clang builtin include directories (needed for __clang_hip_runtime_wrapper.h)
    # These must be explicitly added because -nostdinc disables builtin includes
    common_compiler_flags.append("-isystem" + rocm_path + "/llvm/lib/clang/" + ctx.attr.clang_version + "/include")
    common_compiler_flags.append("-isystem" + rocm_path + "/include")

    # Add architecture flags
    for arch in ctx.attr.amdgpu_targets:
        common_compiler_flags.append("--offload-arch=" + arch)

    # ROCm-specific compilation flags
    common_compiler_flags.extend([
        "-fno-gpu-rdc",  # No relocatable device code - embed kernels as fat binaries
        "-fcuda-flush-denormals-to-zero",
    ])

    # ROCm preprocessor definitions
    common_compiler_flags.extend([
        "-DTENSORFLOW_USE_ROCM=1",
        "-D__HIP_PLATFORM_AMD__",
        "-DEIGEN_USE_HIP",
        "-DUSE_ROCM",
    ])

    # Warning flags
    common_compiler_flags.append("-Wno-unused-result")

    # PIC for shared libraries
    common_compiler_flags.append("-fPIC")

    # C++ only flags
    cpp_only_flags = [
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
            # C++ only flags
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
            doc = "Label pointing to the ROCm toolkit.",
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
    },
    provides = [FeatureInfo],
    doc = """
Creates a toolchain feature for ROCm/HIP compilation.

Sets environment variables (HIPCC_PATH, ROCM_PATH, HIPCC_VERSION, ROCM_CLANG_VERSION)
and compiler flags (--rocm-path, --offload-arch, etc.) for ROCm compilation.
""",
)
