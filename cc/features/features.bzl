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
    "flag_group",
    "flag_set",
    _feature = "feature",
)
load(
    "@rules_ml_toolchain//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl",
    "CcToolchainImportInfo",
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

def _file_to_library_flag(file):
    lib_prefix = "lib"
    if file.basename.startswith(lib_prefix):
        library_name = file.basename.replace("." + file.extension, "")
        library_flag = "-l" + library_name[len(lib_prefix):]
    else:
        library_flag = file.path

    return library_flag

ASAN_COMMON_LIBS = [
    "libclang_rt.asan_static.a",
]

ASAN_EXEC_LIBS = [
    "libclang_rt.asan.a",
]

ASAN_EXEC_SYMS = [
    "libclang_rt.asan.a.syms",
]

ASAN_COMPILER_FLAGS = [
    "-fsanitize=address",
    "-fno-omit-frame-pointer",
    "-fno-sanitize-memory-param-retval",
    "-fsanitize-address-use-after-scope",
    "-fsanitize-address-globals-dead-stripping",
    "-fno-assume-sane-operator-new",
]

ASAN_LINKER_FLAGS = [
    "-fsanitize=address",
]

def _filter_asan_common_libs(flags):
    return _filter_flags_by_keys(flags, ASAN_COMMON_LIBS)

def _filter_asan_exec_libs(flags):
    return _filter_flags_by_keys(flags, ASAN_EXEC_LIBS)

def _filter_asan_exec_syms(flags):
    return _filter_flags_by_keys(flags, ASAN_EXEC_SYMS)

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

def _import_asan_feature_impl(ctx):
    toolchain_import_info = ctx.attr.toolchain_import[CcToolchainImportInfo]

    flag_sets = []

    compiler_flags = depset([
        flag
        for flag in ASAN_COMPILER_FLAGS
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

    common_linker_flags = depset([
        ("-Wl,--whole-archive\n" + file_path + "\n-Wl,--no-whole-archive")
        for file_path in _filter_asan_common_libs([
            file.path
            for file in toolchain_import_info
                .linking_context.additional_libs.to_list()
        ])
    ]).to_list()

    if common_linker_flags:
        flag_sets.append(flag_set(
            actions = CC_LINK_EXECUTABLE_ACTION_NAMES + DYNAMIC_LIBRARY_LINK_ACTION_NAMES + [ACTION_NAMES.cpp_link_nodeps_dynamic_library],
            flag_groups = [
                flag_group(
                    flags = linker_dir_flags + common_linker_flags,
                ),
            ],
        ))

    exec_linker_flags = depset([
        ("-Wl,--whole-archive\n" + file_path + "\n-Wl,--no-whole-archive")
        for file_path in _filter_asan_exec_libs([
            file.path
            for file in toolchain_import_info
                .linking_context.additional_libs.to_list()
        ])
    ]).to_list()

    exec_linker_syms_flags = depset(_filter_asan_exec_syms([
        ("-Wl,--dynamic-list=" + file.path)
        for file in toolchain_import_info
            .linking_context.additional_libs.to_list()
    ])).to_list()

    linker_actions = list(CC_LINK_EXECUTABLE_ACTION_NAMES)
    if ctx.attr.dynamic_lib_treat_as_executable:
        linker_actions += DYNAMIC_LIBRARY_LINK_ACTION_NAMES

    if exec_linker_flags or exec_linker_syms_flags:
        flag_sets.append(flag_set(
            actions = linker_actions,
            flag_groups = [
                flag_group(
                    flags = exec_linker_flags + exec_linker_syms_flags,
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

cc_toolchain_import_asan_feature = rule(
    _import_asan_feature_impl,
    attrs = {
        "enabled": attr.bool(default = False),
        "provides": attr.string_list(),
        "requires": attr.string_list(),
        "implies": attr.string_list(),
        "toolchain_import": attr.label(
            mandatory = True,
            providers = [CcToolchainImportInfo],
        ),
        "dynamic_lib_treat_as_executable": attr.bool(
            default = False,
        ),
    },
    provides = [FeatureInfo, DefaultInfo],
)
