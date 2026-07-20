
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
    "flag_group",
    "flag_set",
    _feature = "feature",
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

def _compiler_input_feature_impl(ctx):
    flag_sets = [
        flag_set(
            actions = [
                ACTION_NAMES.assemble,
                ACTION_NAMES.preprocess_assemble,
                ACTION_NAMES.linkstamp_compile,
                ACTION_NAMES.c_compile,
                ACTION_NAMES.cpp_compile,
                ACTION_NAMES.cpp_header_parsing,    # Remove for bazel 9
                ACTION_NAMES.cpp_module_compile,
                ACTION_NAMES.cpp_module_codegen,
                ACTION_NAMES.cpp_module_deps_scanning,
                ACTION_NAMES.cpp20_module_compile,
                ACTION_NAMES.cpp20_module_codegen,
                ACTION_NAMES.objc_compile,
                ACTION_NAMES.objcpp_compile,
                ACTION_NAMES.lto_backend,
            ],
            flag_groups = [
                flag_group(
                    flags = ["-c", "%{source_file}"],
                    expand_if_available = "source_file",
                ),
            ],
        ),
#        flag_set(
#            actions = [
#                ACTION_NAMES.cpp_header_parsing,
#            ],
#            flag_groups = [
#                flag_group(
#                    flags = ["%{source_file}"],
#                    expand_if_available = "source_file",
#                ),
#            ],
#        ),
    ]

    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            provides = ctx.attr.provides,
            implies = [target.label.name for target in ctx.attr.implies],
            flag_sets = flag_sets,
        ),
    ]

compiler_input_feature = rule(
    _compiler_input_feature_impl,
    attrs = {
        "enabled": attr.bool(default = False),
        "provides": attr.string_list(),
        "requires": attr.string_list(),
        "implies": attr.string_list(),
    },
    provides = [FeatureInfo],
)

def _compiler_output_feature_impl(ctx):
    flag_sets = [
        flag_set(
            actions = [
                ACTION_NAMES.assemble,
                ACTION_NAMES.preprocess_assemble,
                ACTION_NAMES.linkstamp_compile,
                ACTION_NAMES.c_compile,
                ACTION_NAMES.cpp_compile,
                ACTION_NAMES.cpp_header_parsing,
                ACTION_NAMES.cpp_module_compile,
                ACTION_NAMES.cpp_module_codegen,
                ACTION_NAMES.cpp_module_deps_scanning,
                ACTION_NAMES.cpp20_module_compile,
                ACTION_NAMES.cpp20_module_codegen,
                ACTION_NAMES.objc_compile,
                ACTION_NAMES.objcpp_compile,
                ACTION_NAMES.lto_backend,
            ],
            flag_groups = [
                flag_group(
                    flags = ["-S"],
                    expand_if_available = "output_assembly_file",
                ),
                flag_group(
                    flags = ["-E"],
                    expand_if_available = "output_preprocess_file",
                ),
                flag_group(
                    flags = ["-o", "%{output_file}"],
                    expand_if_available = "output_file",
                ),
            ],
        ),
    ]

    env_sets = [
        env_set(
            actions = [
                ACTION_NAMES.cpp_module_deps_scanning,
            ],
            env_entries = [
                env_entry(
                    key = "DEPS_SCANNER_OUTPUT_FILE",
                    value = "%{output_file}",
                    expand_if_available = "output_file",
                ),
            ],
        ),
    ]

    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            provides = ctx.attr.provides,
            implies = [target.label.name for target in ctx.attr.implies],
            flag_sets = flag_sets,
            env_sets = env_sets,
        ),
    ]


compiler_output_feature = rule(
    _compiler_output_feature_impl,
    attrs = {
        "enabled": attr.bool(default = False),
        "provides": attr.string_list(),
        "requires": attr.string_list(),
        "implies": attr.string_list(),
    },
    provides = [FeatureInfo],
)

def _user_compile_feature_impl(ctx):
    flag_sets = [
        flag_set(
            actions = ALL_COMPILE_ACTIONS,
            flag_groups = [
                flag_group(
                    flags = ["%{user_compile_flags}"],
                    iterate_over = "user_compile_flags",
                    expand_if_available = "user_compile_flags",
                ),
            ],
        ),
    ]

    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            provides = ctx.attr.provides,
            implies = [target.label.name for target in ctx.attr.implies],
            flag_sets = flag_sets,
        ),
    ]

user_compile_feature = rule(
    _user_compile_feature_impl,
    attrs = {
        "enabled": attr.bool(default = False),
        "provides": attr.string_list(),
        "requires": attr.string_list(),
        "implies": attr.string_list(),
    },
    provides = [FeatureInfo],
)

def _include_paths_feature_impl(ctx):
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
                ACTION_NAMES.clif_match,
                ACTION_NAMES.objc_compile,
                ACTION_NAMES.objcpp_compile,
            ],
            flag_groups = [
                flag_group(
                    flags = ["-iquote", "%{quote_include_paths}"],
                    iterate_over = "quote_include_paths",
                ),
                flag_group(
                    flags = ["-I%{include_paths}"],
                    iterate_over = "include_paths",
                ),
                flag_group(
                    flags = ["-isystem", "%{system_include_paths}"],
                    iterate_over = "system_include_paths",
                ),
            ],
        ),
    ]

    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            provides = ctx.attr.provides,
            implies = [target.label.name for target in ctx.attr.implies],
            flag_sets = flag_sets,
        ),
    ]

include_paths_feature = rule(
    _include_paths_feature_impl,
    attrs = {
        "enabled": attr.bool(default = False),
        "provides": attr.string_list(),
        "requires": attr.string_list(),
        "implies": attr.string_list(),
    },
    provides = [FeatureInfo],
)

def _external_include_paths_feature_impl(ctx):
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
                ACTION_NAMES.cpp20_module_codegen,
                ACTION_NAMES.clif_match,
                ACTION_NAMES.objc_compile,
                ACTION_NAMES.objcpp_compile,
            ],
            flag_groups = [
                flag_group(
                    flags = ["-isystem", "%{external_include_paths}"],
                    iterate_over = "external_include_paths",
                    expand_if_available = "external_include_paths",
                ),
            ],
        ),
    ]

    return [
        feature(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            provides = ctx.attr.provides,
            implies = [target.label.name for target in ctx.attr.implies],
            flag_sets = flag_sets,
        ),
    ]

external_include_paths_feature = rule(
    _external_include_paths_feature_impl,
    attrs = {
        "enabled": attr.bool(default = False),
        "provides": attr.string_list(),
        "requires": attr.string_list(),
        "implies": attr.string_list(),
    },
    provides = [FeatureInfo],
)
