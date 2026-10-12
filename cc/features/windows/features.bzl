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

"""Windows C++ toolchain feature definitions matching Bazel's standard Windows clang-cl toolchain."""

load(
    "@rules_cc//cc:action_names.bzl",
    "ACTION_NAMES",
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
    "variable_with_value",
    "with_feature_set",
)

ALL_COMPILE_ACTIONS = [
    ACTION_NAMES.c_compile,
    ACTION_NAMES.cpp_compile,
    ACTION_NAMES.linkstamp_compile,
    ACTION_NAMES.assemble,
    ACTION_NAMES.preprocess_assemble,
    ACTION_NAMES.cpp_header_parsing,
    ACTION_NAMES.cpp_module_compile,
    ACTION_NAMES.cpp_module_codegen,
    ACTION_NAMES.cpp_module_deps_scanning,
    ACTION_NAMES.cpp20_module_compile,
    ACTION_NAMES.cpp20_module_codegen,
    ACTION_NAMES.clif_match,
    ACTION_NAMES.lto_backend,
]

ALL_CPP_COMPILE_ACTIONS = [
    ACTION_NAMES.cpp_compile,
    ACTION_NAMES.linkstamp_compile,
    ACTION_NAMES.cpp_header_parsing,
    ACTION_NAMES.cpp_module_compile,
    ACTION_NAMES.cpp_module_codegen,
    ACTION_NAMES.cpp_module_deps_scanning,
    ACTION_NAMES.cpp20_module_compile,
    ACTION_NAMES.cpp20_module_codegen,
    ACTION_NAMES.clif_match,
]

ALL_LINK_ACTIONS = [
    ACTION_NAMES.cpp_link_executable,
    ACTION_NAMES.cpp_link_dynamic_library,
    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
]

MSVC_COMPILE_ENV_ACTIONS = [
    ACTION_NAMES.c_compile,
    ACTION_NAMES.linkstamp_compile,
    ACTION_NAMES.cpp_compile,
    ACTION_NAMES.cpp_module_compile,
    ACTION_NAMES.cpp_module_codegen,
    ACTION_NAMES.cpp_header_parsing,
    ACTION_NAMES.cpp_module_deps_scanning,
    ACTION_NAMES.cpp20_module_compile,
    ACTION_NAMES.cpp20_module_codegen,
    ACTION_NAMES.assemble,
    ACTION_NAMES.preprocess_assemble,
]

def _windows_msvc_env_feature_impl(ctx):
    path_val = ctx.attr.msvc_env_path or "msvc_not_found"
    tmp_val = ctx.attr.msvc_env_tmp or "msvc_not_found"
    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            env_sets = [
                env_set(
                    actions = MSVC_COMPILE_ENV_ACTIONS + ALL_LINK_ACTIONS + [
                        ACTION_NAMES.cpp_link_static_library,
                    ],
                    env_entries = [
                        env_entry(key = "PATH", value = path_val),
                        env_entry(key = "TMP", value = tmp_val),
                        env_entry(key = "TEMP", value = tmp_val),
                    ],
                ),
            ],
            implies = [target.label.name for target in ctx.attr.implies],
        ),
    ]

windows_msvc_env_feature = rule(
    implementation = _windows_msvc_env_feature_impl,
    attrs = {
        "enabled": attr.bool(default = False),
        "msvc_env_path": attr.string(default = "msvc_not_found"),
        "msvc_env_tmp": attr.string(default = "msvc_not_found"),
        "implies": attr.label_list(default = []),
    },
    provides = [FeatureInfo],
)

def _windows_msvc_compile_env_feature_impl(ctx):
    include_val = ctx.attr.msvc_env_include or "msvc_not_found"
    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            env_sets = [
                env_set(
                    actions = MSVC_COMPILE_ENV_ACTIONS,
                    env_entries = [
                        env_entry(key = "INCLUDE", value = include_val),
                    ],
                ),
            ],
        ),
    ]

windows_msvc_compile_env_feature = rule(
    implementation = _windows_msvc_compile_env_feature_impl,
    attrs = {
        "enabled": attr.bool(default = False),
        "msvc_env_include": attr.string(default = "msvc_not_found"),
    },
    provides = [FeatureInfo],
)

def _windows_msvc_link_env_feature_impl(ctx):
    lib_val = ctx.attr.msvc_env_lib or "msvc_not_found"
    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            env_sets = [
                env_set(
                    actions = ALL_LINK_ACTIONS + [
                        ACTION_NAMES.cpp_link_static_library,
                    ],
                    env_entries = [
                        env_entry(key = "LIB", value = lib_val),
                    ],
                ),
            ],
        ),
    ]

windows_msvc_link_env_feature = rule(
    implementation = _windows_msvc_link_env_feature_impl,
    attrs = {
        "enabled": attr.bool(default = False),
        "msvc_env_lib": attr.string(default = "msvc_not_found"),
    },
    provides = [FeatureInfo],
)

def _windows_include_paths_feature_impl(ctx):
    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.assemble,
                        ACTION_NAMES.preprocess_assemble,
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.linkstamp_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_header_parsing,
                        ACTION_NAMES.cpp_module_compile,
                        ACTION_NAMES.cpp_module_deps_scanning,
                        ACTION_NAMES.cpp20_module_compile,
                    ],
                    flag_groups = [
                        flag_group(
                            flags = ["/I%{quote_include_paths}"],
                            iterate_over = "quote_include_paths",
                        ),
                        flag_group(
                            flags = ["/I%{include_paths}"],
                            iterate_over = "include_paths",
                        ),
                        flag_group(
                            flags = ["/I%{system_include_paths}"],
                            iterate_over = "system_include_paths",
                        ),
                    ],
                ),
            ],
        ),
    ]

windows_include_paths_feature = rule(
    implementation = _windows_include_paths_feature_impl,
    attrs = {
        "enabled": attr.bool(default = True),
    },
    provides = [FeatureInfo],
)

def _windows_external_include_paths_feature_impl(ctx):
    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.preprocess_assemble,
                        ACTION_NAMES.linkstamp_compile,
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_header_parsing,
                        ACTION_NAMES.cpp_module_compile,
                        ACTION_NAMES.cpp_module_deps_scanning,
                        ACTION_NAMES.cpp20_module_compile,
                    ],
                    flag_groups = [
                        flag_group(
                            flags = ["/external:I%{external_include_paths}"],
                            iterate_over = "external_include_paths",
                            expand_if_available = "external_include_paths",
                        ),
                    ],
                ),
            ],
        ),
    ]

windows_external_include_paths_feature = rule(
    implementation = _windows_external_include_paths_feature_impl,
    attrs = {
        "enabled": attr.bool(default = False),
    },
    provides = [FeatureInfo],
)

def _windows_preprocessor_defines_feature_impl(ctx):
    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.assemble,
                        ACTION_NAMES.preprocess_assemble,
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.linkstamp_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_header_parsing,
                        ACTION_NAMES.cpp_module_compile,
                        ACTION_NAMES.cpp_module_deps_scanning,
                        ACTION_NAMES.cpp20_module_compile,
                    ],
                    flag_groups = [
                        flag_group(
                            flags = ["/D%{preprocessor_defines}"],
                            iterate_over = "preprocessor_defines",
                        ),
                    ],
                ),
            ],
        ),
    ]

windows_preprocessor_defines_feature = rule(
    implementation = _windows_preprocessor_defines_feature_impl,
    attrs = {
        "enabled": attr.bool(default = True),
    },
    provides = [FeatureInfo],
)

def _windows_parse_showincludes_feature_impl(ctx):
    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.preprocess_assemble,
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.linkstamp_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_header_parsing,
                        ACTION_NAMES.cpp_module_compile,
                        ACTION_NAMES.cpp_module_deps_scanning,
                        ACTION_NAMES.cpp20_module_compile,
                    ],
                    flag_groups = [flag_group(flags = ["/showIncludes"])],
                ),
            ],
            env_sets = [
                env_set(
                    actions = [
                        ACTION_NAMES.preprocess_assemble,
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.linkstamp_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_header_parsing,
                        ACTION_NAMES.cpp_module_compile,
                        ACTION_NAMES.cpp_module_deps_scanning,
                        ACTION_NAMES.cpp20_module_compile,
                    ],
                    env_entries = [env_entry(key = "VSLANG", value = "1033")],
                ),
            ],
        ),
    ]

windows_parse_showincludes_feature = rule(
    implementation = _windows_parse_showincludes_feature_impl,
    attrs = {
        "enabled": attr.bool(default = True),
    },
    provides = [FeatureInfo],
)

def _windows_generate_pdb_file_feature_impl(ctx):
    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            requires = [
                feature_set(features = ["dbg"]),
                feature_set(features = ["fastbuild"]),
            ],
        ),
    ]

windows_generate_pdb_file_feature = rule(
    implementation = _windows_generate_pdb_file_feature_impl,
    attrs = {
        "enabled": attr.bool(default = False),
    },
    provides = [FeatureInfo],
)

def _windows_linkstamps_feature_impl(ctx):
    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            flag_sets = [
                flag_set(
                    actions = ALL_LINK_ACTIONS,
                    flag_groups = [
                        flag_group(
                            flags = ["%{linkstamp_paths}"],
                            iterate_over = "linkstamp_paths",
                            expand_if_available = "linkstamp_paths",
                        ),
                    ],
                ),
            ],
        ),
    ]

windows_linkstamps_feature = rule(
    implementation = _windows_linkstamps_feature_impl,
    attrs = {
        "enabled": attr.bool(default = False),
    },
    provides = [FeatureInfo],
)

def _windows_archiver_flags_feature_impl(ctx):
    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            flag_sets = [
                flag_set(
                    actions = [ACTION_NAMES.cpp_link_static_library],
                    flag_groups = [
                        flag_group(
                            flags = ["/OUT:%{output_execpath}"],
                            expand_if_available = "output_execpath",
                        ),
                        flag_group(
                            flags = ["%{user_archiver_flags}"],
                            iterate_over = "user_archiver_flags",
                            expand_if_available = "user_archiver_flags",
                        ),
                        flag_group(
                            flags = ["/MACHINE:" + ctx.attr.arch],
                        ),
                    ],
                ),
            ],
        ),
    ]

windows_archiver_flags_feature = rule(
    implementation = _windows_archiver_flags_feature_impl,
    attrs = {
        "enabled": attr.bool(default = False),
        "arch": attr.string(default = "X64"),
    },
    provides = [FeatureInfo],
)

def _windows_input_param_flags_feature_impl(ctx):
    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.cpp_link_dynamic_library,
                        ACTION_NAMES.cpp_link_nodeps_dynamic_library,
                    ],
                    flag_groups = [
                        flag_group(
                            flags = ["/IMPLIB:%{interface_library_output_path}"],
                            expand_if_available = "interface_library_output_path",
                        ),
                    ],
                ),
                flag_set(
                    actions = ALL_LINK_ACTIONS + [
                        ACTION_NAMES.cpp_link_static_library,
                    ],
                    flag_groups = [
                        flag_group(
                            iterate_over = "libraries_to_link",
                            flag_groups = [
                                flag_group(
                                    iterate_over = "libraries_to_link.object_files",
                                    flag_groups = [flag_group(flags = ["%{libraries_to_link.object_files}"])],
                                    expand_if_equal = variable_with_value(
                                        name = "libraries_to_link.type",
                                        value = "object_file_group",
                                    ),
                                ),
                                flag_group(
                                    flag_groups = [flag_group(flags = ["%{libraries_to_link.name}"])],
                                    expand_if_equal = variable_with_value(
                                        name = "libraries_to_link.type",
                                        value = "object_file",
                                    ),
                                ),
                                flag_group(
                                    flag_groups = [flag_group(flags = ["%{libraries_to_link.name}"])],
                                    expand_if_equal = variable_with_value(
                                        name = "libraries_to_link.type",
                                        value = "interface_library",
                                    ),
                                ),
                                flag_group(
                                    flag_groups = [
                                        flag_group(
                                            flags = ["%{libraries_to_link.name}"],
                                            expand_if_false = "libraries_to_link.is_whole_archive",
                                        ),
                                        flag_group(
                                            flags = ["/WHOLEARCHIVE:%{libraries_to_link.name}"],
                                            expand_if_true = "libraries_to_link.is_whole_archive",
                                        ),
                                    ],
                                    expand_if_equal = variable_with_value(
                                        name = "libraries_to_link.type",
                                        value = "static_library",
                                    ),
                                ),
                            ],
                            expand_if_available = "libraries_to_link",
                        ),
                    ],
                ),
            ],
        ),
    ]

windows_input_param_flags_feature = rule(
    implementation = _windows_input_param_flags_feature_impl,
    attrs = {
        "enabled": attr.bool(default = False),
    },
    provides = [FeatureInfo],
)

def _windows_user_link_flags_feature_impl(ctx):
    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            flag_sets = [
                flag_set(
                    actions = ALL_LINK_ACTIONS,
                    flag_groups = [
                        flag_group(
                            flags = ["%{user_link_flags}"],
                            iterate_over = "user_link_flags",
                            expand_if_available = "user_link_flags",
                        ),
                    ],
                ),
            ],
        ),
    ]

windows_user_link_flags_feature = rule(
    implementation = _windows_user_link_flags_feature_impl,
    attrs = {
        "enabled": attr.bool(default = False),
    },
    provides = [FeatureInfo],
)

def _windows_static_link_msvcrt_feature_impl(ctx):
    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_module_compile,
                        ACTION_NAMES.cpp_module_codegen,
                        ACTION_NAMES.cpp20_module_compile,
                        ACTION_NAMES.cpp20_module_codegen,
                    ],
                    flag_groups = [flag_group(flags = ["/MT"])],
                    with_features = [with_feature_set(not_features = ["dbg"])],
                ),
                flag_set(
                    actions = [
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_module_compile,
                        ACTION_NAMES.cpp_module_codegen,
                        ACTION_NAMES.cpp20_module_compile,
                        ACTION_NAMES.cpp20_module_codegen,
                    ],
                    flag_groups = [flag_group(flags = ["/MTd"])],
                    with_features = [with_feature_set(features = ["dbg"])],
                ),
                flag_set(
                    actions = ALL_LINK_ACTIONS,
                    flag_groups = [flag_group(flags = ["/DEFAULTLIB:libcmt.lib"])],
                    with_features = [with_feature_set(not_features = ["dbg"])],
                ),
                flag_set(
                    actions = ALL_LINK_ACTIONS,
                    flag_groups = [flag_group(flags = ["/DEFAULTLIB:libcmtd.lib"])],
                    with_features = [with_feature_set(features = ["dbg"])],
                ),
            ],
        ),
    ]

windows_static_link_msvcrt_feature = rule(
    implementation = _windows_static_link_msvcrt_feature_impl,
    attrs = {
        "enabled": attr.bool(default = False),
    },
    provides = [FeatureInfo],
)

def _windows_dynamic_link_msvcrt_feature_impl(ctx):
    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_module_compile,
                        ACTION_NAMES.cpp_module_codegen,
                        ACTION_NAMES.cpp20_module_compile,
                        ACTION_NAMES.cpp20_module_codegen,
                    ],
                    flag_groups = [flag_group(flags = ["/MD"])],
                    with_features = [with_feature_set(not_features = ["dbg", "static_link_msvcrt"])],
                ),
                flag_set(
                    actions = [
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_module_compile,
                        ACTION_NAMES.cpp_module_codegen,
                        ACTION_NAMES.cpp20_module_compile,
                        ACTION_NAMES.cpp20_module_codegen,
                    ],
                    flag_groups = [flag_group(flags = ["/MDd"])],
                    with_features = [with_feature_set(features = ["dbg"], not_features = ["static_link_msvcrt"])],
                ),
                flag_set(
                    actions = ALL_LINK_ACTIONS,
                    flag_groups = [flag_group(flags = ["/DEFAULTLIB:msvcrt.lib"])],
                    with_features = [with_feature_set(not_features = ["dbg", "static_link_msvcrt"])],
                ),
                flag_set(
                    actions = ALL_LINK_ACTIONS,
                    flag_groups = [flag_group(flags = ["/DEFAULTLIB:msvcrtd.lib"])],
                    with_features = [with_feature_set(features = ["dbg"], not_features = ["static_link_msvcrt"])],
                ),
            ],
        ),
    ]

windows_dynamic_link_msvcrt_feature = rule(
    implementation = _windows_dynamic_link_msvcrt_feature_impl,
    attrs = {
        "enabled": attr.bool(default = True),
    },
    provides = [FeatureInfo],
)

def _windows_disable_assertions_feature_impl(ctx):
    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_module_compile,
                        ACTION_NAMES.cpp_module_codegen,
                        ACTION_NAMES.cpp20_module_compile,
                        ACTION_NAMES.cpp20_module_codegen,
                    ],
                    flag_groups = [flag_group(flags = ["/DNDEBUG"])],
                    with_features = [with_feature_set(features = ["opt"])],
                ),
            ],
        ),
    ]

windows_disable_assertions_feature = rule(
    implementation = _windows_disable_assertions_feature_impl,
    attrs = {
        "enabled": attr.bool(default = True),
    },
    provides = [FeatureInfo],
)

def _windows_smaller_binary_feature_impl(ctx):
    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_module_compile,
                        ACTION_NAMES.cpp_module_codegen,
                        ACTION_NAMES.cpp20_module_compile,
                        ACTION_NAMES.cpp20_module_codegen,
                    ],
                    flag_groups = [flag_group(flags = ["/Gy", "/Gw"])],
                    with_features = [with_feature_set(features = ["opt"])],
                ),
                flag_set(
                    actions = ALL_LINK_ACTIONS,
                    flag_groups = [flag_group(flags = ["/OPT:ICF", "/OPT:REF"])],
                    with_features = [with_feature_set(features = ["opt"])],
                ),
            ],
        ),
    ]

windows_smaller_binary_feature = rule(
    implementation = _windows_smaller_binary_feature_impl,
    attrs = {
        "enabled": attr.bool(default = True),
    },
    provides = [FeatureInfo],
)

def _windows_user_compile_flags_feature_impl(ctx):
    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.preprocess_assemble,
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.linkstamp_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_header_parsing,
                        ACTION_NAMES.cpp_module_compile,
                        ACTION_NAMES.cpp_module_codegen,
                        ACTION_NAMES.cpp_module_deps_scanning,
                        ACTION_NAMES.cpp20_module_compile,
                        ACTION_NAMES.cpp20_module_codegen,
                    ],
                    flag_groups = [
                        flag_group(
                            flags = ["%{user_compile_flags}"],
                            iterate_over = "user_compile_flags",
                            expand_if_available = "user_compile_flags",
                        ),
                    ],
                ),
            ],
        ),
    ]

windows_user_compile_flags_feature = rule(
    implementation = _windows_user_compile_flags_feature_impl,
    attrs = {
        "enabled": attr.bool(default = True),
    },
    provides = [FeatureInfo],
)

def _windows_unfiltered_compile_flags_feature_impl(ctx):
    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.preprocess_assemble,
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.linkstamp_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_header_parsing,
                        ACTION_NAMES.cpp_module_compile,
                        ACTION_NAMES.cpp_module_codegen,
                        ACTION_NAMES.cpp_module_deps_scanning,
                        ACTION_NAMES.cpp20_module_compile,
                        ACTION_NAMES.cpp20_module_codegen,
                    ],
                    flag_groups = [
                        flag_group(
                            flags = ["%{unfiltered_compile_flags}"],
                            iterate_over = "unfiltered_compile_flags",
                            expand_if_available = "unfiltered_compile_flags",
                        ),
                    ],
                ),
            ],
        ),
    ]

windows_unfiltered_compile_flags_feature = rule(
    implementation = _windows_unfiltered_compile_flags_feature_impl,
    attrs = {
        "enabled": attr.bool(default = True),
    },
    provides = [FeatureInfo],
)

def _windows_compiler_output_flags_feature_impl(ctx):
    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            flag_sets = [
                flag_set(
                    actions = [ACTION_NAMES.assemble],
                    flag_groups = [
                        flag_group(
                            flag_groups = [
                                flag_group(
                                    flags = ["/Fo%{output_file}", "/Zi"],
                                    expand_if_available = "output_file",
                                    expand_if_not_available = "output_preprocess_file",
                                ),
                            ],
                            expand_if_not_available = "output_assembly_file",
                        ),
                    ],
                ),
                flag_set(
                    actions = [
                        ACTION_NAMES.preprocess_assemble,
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.linkstamp_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_header_parsing,
                        ACTION_NAMES.cpp_module_compile,
                        ACTION_NAMES.cpp_module_codegen,
                        ACTION_NAMES.cpp20_module_compile,
                        ACTION_NAMES.cpp20_module_codegen,
                    ],
                    flag_groups = [
                        flag_group(
                            flag_groups = [
                                flag_group(
                                    flag_groups = [
                                        flag_group(
                                            flags = ["/Fo%{output_file}"],
                                            expand_if_not_available = "output_preprocess_file",
                                        ),
                                    ],
                                    expand_if_not_available = "output_assembly_file",
                                ),
                                flag_group(
                                    flag_groups = [
                                        flag_group(
                                            flags = ["/Fa%{output_file}"],
                                            expand_if_available = "output_assembly_file",
                                        ),
                                    ],
                                    expand_if_not_available = "output_preprocess_file",
                                ),
                                flag_group(
                                    flag_groups = [
                                        flag_group(
                                            flags = ["/P", "/Fi%{output_file}"],
                                            expand_if_available = "output_preprocess_file",
                                        ),
                                    ],
                                    expand_if_not_available = "output_assembly_file",
                                ),
                            ],
                            expand_if_available = "output_file",
                        ),
                    ],
                ),
            ],
            env_sets = [
                env_set(
                    actions = [ACTION_NAMES.cpp_module_deps_scanning],
                    env_entries = [
                        env_entry(
                            key = "DEPS_SCANNER_OUTPUT_FILE",
                            value = "%{output_file}",
                            expand_if_available = "output_file",
                        ),
                    ],
                ),
            ],
        ),
    ]

windows_compiler_output_flags_feature = rule(
    implementation = _windows_compiler_output_flags_feature_impl,
    attrs = {
        "enabled": attr.bool(default = False),
    },
    provides = [FeatureInfo],
)

def _windows_sysroot_feature_impl(ctx):
    flag_sets = [
        flag_set(
            actions = [
                ACTION_NAMES.assemble,
                ACTION_NAMES.preprocess_assemble,
                ACTION_NAMES.c_compile,
                ACTION_NAMES.linkstamp_compile,
                ACTION_NAMES.cpp_compile,
                ACTION_NAMES.cpp_header_parsing,
                ACTION_NAMES.cpp_module_compile,
                ACTION_NAMES.cpp_module_codegen,
                ACTION_NAMES.cpp_module_deps_scanning,
                ACTION_NAMES.cpp20_module_compile,
                ACTION_NAMES.cpp20_module_codegen,
            ] + ALL_LINK_ACTIONS,
            flag_groups = [
                flag_group(
                    flags = ["--sysroot=%{sysroot}"],
                    iterate_over = "sysroot",
                    expand_if_available = "sysroot",
                ),
            ],
        ),
    ]
    if ctx.attr.target:
        flag_sets.append(
            flag_set(
                actions = [
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.linkstamp_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.cpp_module_codegen,
                    ACTION_NAMES.cpp_module_deps_scanning,
                    ACTION_NAMES.cpp20_module_compile,
                    ACTION_NAMES.cpp20_module_codegen,
                ],
                flag_groups = [
                    flag_group(
                        flags = ["--target=" + ctx.attr.target],
                    ),
                ],
            ),
        )
    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            flag_sets = flag_sets,
        ),
    ]

windows_sysroot_feature = rule(
    implementation = _windows_sysroot_feature_impl,
    attrs = {
        "enabled": attr.bool(default = False),
        "target": attr.string(default = "x86_64-pc-windows-msvc"),
    },
    provides = [FeatureInfo],
)
