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
    "@rules_cc//cc:action_names.bzl",
    "ACTION_NAMES",
    "ALL_CC_COMPILE_ACTION_NAMES",
    "CC_LINK_EXECUTABLE_ACTION_NAMES",
    "DYNAMIC_LIBRARY_LINK_ACTION_NAMES",
)
load(
    "@rules_cc//cc:cc_toolchain_config_lib.bzl",
    "FeatureInfo",
    "env_entry",
    "env_set",
    "feature",
    "flag_group",
    "flag_set",
    _feature = "feature",
)
load(
    "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl",
    "CcToolchainImportInfo",
)
# TODO: Check below lines
#load(
#    "//cc_toolchain/features/cuda_nvcc_feature.bzl",
#    "ALL_ACTIONS",
#)

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

def _cuda_nvcc_feature_impl(ctx):
    return _feature(
        name = ctx.label.name,
        enabled = ctx.attr.enabled,
        provides = ctx.attr.provides,
        #implies = ["cuda_nvcc_feature"] + [label.name for label in ctx.attr.implies],
        flag_sets = [
            flag_set(
                actions = CC_LINK_EXECUTABLE_ACTION_NAMES +
                          DYNAMIC_LIBRARY_LINK_ACTION_NAMES +
                          ALL_CC_COMPILE_ACTION_NAMES,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-Wno-invalid-partial-specialization",
                            "--cuda-path=" + ctx.attr.bin.label.workspace_root,
                        ],
                    ),
                ],
            ),
        ],
        env_sets = [env_set(
            actions = ALL_ACTIONS,
            env_entries = [
                env_entry("NVCC_PATH", (ctx.attr.bin.label.workspace_root + "/" + ctx.attr.bin.label.name)),
                env_entry("NVCC_VERSION", ctx.attr.version),
            ],
        )],
    )

cuda_nvcc_feature = rule(
    _cuda_nvcc_feature_impl,
    attrs = {
        "enabled": attr.bool(default = False),
        "provides": attr.string_list(),
        "requires": attr.string_list(),
        "implies": attr.string_list(),
        "bin": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        "version": attr.string(
            mandatory = True,
        ),
    },
    provides = [FeatureInfo],
)
