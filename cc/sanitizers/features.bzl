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
    "ACTION_NAME_GROUPS",
    "ALL_CC_COMPILE_ACTION_NAMES",
    "ALL_CC_LINK_ACTION_NAMES",
    "ALL_CPP_COMPILE_ACTION_NAMES",
    "CC_LINK_EXECUTABLE_ACTION_NAMES",
    "DYNAMIC_LIBRARY_LINK_ACTION_NAMES",
)
load(
    "@rules_cc//cc:cc_toolchain_config_lib.bzl",
    "FeatureInfo",
    "env_entry",
    "env_set",
    "feature",
    "feature_set",
    "flag_group",
    "flag_set",
    _feature = "feature",
)
load(
    "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl",
    "CcToolchainImportInfo",
)

SANITIZER_LINK_ACTIONS = [
    ACTION_NAMES.cpp_link_executable,
    ACTION_NAMES.cpp_link_dynamic_library,
    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
]

def _file_to_library_flag(file):
    lib_prefix = "lib"
    if file.basename.startswith(lib_prefix):
        library_name = file.basename.replace("." + file.extension, "")
        library_flag = "-l" + library_name[len(lib_prefix):]
    else:
        library_flag = file.path

    return library_flag

def _filter_flags_by_keys(flags, keys):
    libFlags = []
    for flag in flags:
        needed = False
        for key in keys:
            if flag.endswith(key):
                needed = True
                break

        if needed:
            libFlags.append(flag)

    return libFlags

def _import_sanitizer_feature_impl(ctx):
    toolchain_import_info = ctx.attr.toolchain_import[CcToolchainImportInfo]
    flag_sets = []

    compiler_flags = depset([
        flag
        for flag in ([
            "-fno-omit-frame-pointer",
            "-fno-sanitize-recover=all",
        ] + ctx.attr.compiler_flags)
    ]).to_list()

    if compiler_flags:
        flag_sets.append(flag_set(
            actions = ALL_CC_COMPILE_ACTION_NAMES,
            flag_groups = [
                flag_group(
                    flags = compiler_flags,
                ),
            ],
        ))

    linker_flags = depset([
        flag
        for flag in ctx.attr.linker_flags
    ]).to_list()

    linker_dir_flags = depset([
        "-L" + file.dirname
        for file in toolchain_import_info
            .linking_context.static_libraries.to_list()
    ] + [
        "-L" + file.dirname
        for file in toolchain_import_info
            .linking_context.dynamic_libraries.to_list()
    ] + [
        "-L" + file.dirname
        for file in toolchain_import_info
            .linking_context.additional_libs.to_list()
    ]).to_list()

    if linker_flags or linker_dir_flags:
        flag_sets.append(flag_set(
            actions = SANITIZER_LINK_ACTIONS,
            flag_groups = [
                flag_group(
                    flags = linker_flags + linker_dir_flags,
                ),
            ],
        ))

    library_feature = _feature(
        name = ctx.label.name,
        enabled = ctx.attr.enabled,
        flag_sets = flag_sets,
        implies = ctx.attr.implies,
        provides = ctx.attr.provides,
    )
    return [library_feature, ctx.attr.toolchain_import[DefaultInfo]]

cc_toolchain_import_sanitizer_feature = rule(
    _import_sanitizer_feature_impl,
    attrs = {
        "enabled": attr.bool(default = False),
        "provides": attr.string_list(),
        "implies": attr.string_list(),
        "toolchain_import": attr.label(
            mandatory = True,
            providers = [CcToolchainImportInfo],
        ),
        "compiler_flags": attr.string_list(
            default = [],
            doc = "The list of flags to pass to the compiler regardless of if \
the target is a C or C++ library.",
            mandatory = True,
        ),
        "linker_flags": attr.string_list(
            default = [],
            doc = "The list of flags to apply when linking.",
            mandatory = True,
        ),
    },
    provides = [FeatureInfo, DefaultInfo],
)

