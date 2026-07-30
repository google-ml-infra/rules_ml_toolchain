# MIT License
#
# Copyright (c) 2021 silvergasp
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

load(
    "@rules_cc//cc:action_names.bzl",
    "ACTION_NAMES",
    "ACTION_NAME_GROUPS",
    "ALL_CC_COMPILE_ACTION_NAMES",
    "ALL_CC_LINK_ACTION_NAMES",
    "CC_LINK_EXECUTABLE_ACTION_NAMES",
    "DYNAMIC_LIBRARY_LINK_ACTION_NAMES",
    "NODEPS_DYNAMIC_LIBRARY_LINK_ACTION_NAMES",
    "TRANSITIVE_LINK_ACTION_NAMES",
)
load(
    "@rules_cc//cc:cc_toolchain_config_lib.bzl",
    "FeatureInfo",
    "action_config",
    "artifact_name_pattern",
    "env_entry",
    "env_set",
    "flag_group",
    "flag_set",
    "feature",
    "feature_set",
    "tool",
    "tool_path",
    "variable_with_value",
    "with_feature_set",
)
load("@rules_cc//cc:defs.bzl", "CcToolchainConfigInfo", "cc_common")

ALL_ACTIONS = (
    ALL_CC_COMPILE_ACTION_NAMES +
    ALL_CC_LINK_ACTION_NAMES +
    CC_LINK_EXECUTABLE_ACTION_NAMES +
    DYNAMIC_LIBRARY_LINK_ACTION_NAMES +
    NODEPS_DYNAMIC_LIBRARY_LINK_ACTION_NAMES +
    TRANSITIVE_LINK_ACTION_NAMES +
    [
        ACTION_NAMES.cpp_module_deps_scanning,
        ACTION_NAMES.cpp_module_codegen,
        ACTION_NAMES.cpp20_module_compile,
        ACTION_NAMES.cpp20_module_codegen,
        ACTION_NAMES.cpp_link_static_library,
    ]
)


#ALL_ACTIONS = [
#    ACTION_NAMES.c_compile,
#    ACTION_NAMES.cpp_compile,
#    ACTION_NAMES.linkstamp_compile,
#    ACTION_NAMES.cc_flags_make_variable,
#    ACTION_NAMES.cpp_module_codegen,
#    ACTION_NAMES.cpp_header_parsing,
#    ACTION_NAMES.cpp_module_compile,
#    ACTION_NAMES.assemble,
#    ACTION_NAMES.preprocess_assemble,
#    ACTION_NAMES.lto_indexing,
#    ACTION_NAMES.lto_backend,
#    ACTION_NAMES.lto_index_for_executable,
#    ACTION_NAMES.lto_index_for_dynamic_library,
#    ACTION_NAMES.lto_index_for_nodeps_dynamic_library,
#    ACTION_NAMES.cpp_link_executable,
#    ACTION_NAMES.cpp_link_dynamic_library,
#    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
#    ACTION_NAMES.cpp_link_static_library,
#    ACTION_NAMES.clif_match,
#]

def parse_headers_support(parse_headers_tool_path):
    """
    Returns action configurations and features for parsing headers.

    Args:
        parse_headers_tool_path: The path to the tool used for parsing headers.

    Returns:
        A tuple containing a list of action configurations and a list of features.
    """
    if not parse_headers_tool_path:
        return [], []
    action_configs = [
        action_config(
            action_name = ACTION_NAMES.cpp_header_parsing,
            tools = [
                tool(path = parse_headers_tool_path),
            ],
            flag_sets = [
                flag_set(
                    flag_groups = [
                        flag_group(
                            flags = [
                                # Note: This treats all headers as C++ headers, which may lead to
                                # parsing failures for C headers that are not valid C++.
                                # For such headers, use features = ["-parse_headers"] to selectively
                                # disable parsing.
                                "-xc++-header",
                                "-fsyntax-only",
                            ],
                        ),
                    ],
                ),
            ],
            implies = [
                # Copied from the legacy feature definition in CppActionConfigs.java.
                "legacy_compile_flags",
                "user_compile_flags",
                "sysroot",
                "unfiltered_compile_flags",
                "compiler_input_flags",
                "compiler_output_flags",
            ],
        ),
    ]
    features = [
        feature(name = "parse_headers"),
    ]
    return action_configs, features

# Copy of action configuration from @rules_cc//cc/...:unix_cc_toolchain_config_lib.bzl
def _get_actions_config(ctx):
    action_configs = []

    llvm_cov = ctx.attr.tool_paths.get("llvm-cov")
    if llvm_cov:
        llvm_cov_action = action_config(
            action_name = ACTION_NAMES.llvm_cov,
            tools = [
                tool(
                    path = llvm_cov,
                ),
            ],
        )
        action_configs.append(llvm_cov_action)

    objcopy = ctx.attr.tool_paths.get("objcopy")
    if objcopy:
        objcopy_action = action_config(
            action_name = ACTION_NAMES.objcopy_embed_data,
            tools = [
                tool(
                    path = objcopy,
                ),
            ],
        )
        action_configs.append(objcopy_action)

    validate_static_library = ctx.attr.tool_paths.get("validate_static_library")
    if validate_static_library:
        validate_static_library_action = action_config(
            action_name = ACTION_NAMES.validate_static_library,
            tools = [
                tool(
                    path = validate_static_library,
                ),
            ],
        )
        action_configs.append(validate_static_library_action)

        symbol_check = feature(
            name = "symbol_check",
            implies = [ACTION_NAMES.validate_static_library],
        )
    else:
        symbol_check = None

    deps_scanner = "cpp-module-deps-scanner_not_found"
    if "cpp-module-deps-scanner" in ctx.attr.tool_paths:
        deps_scanner = ctx.attr.tool_paths["cpp-module-deps-scanner"]
    cc = ctx.attr.tool_paths.get("gcc")
    compile_implies = [
        # keep same with c++-compile
        "legacy_compile_flags",
        "user_compile_flags",
        "sysroot",
        "unfiltered_compile_flags",
        "compiler_input_flags",
        "compiler_output_flags",
    ]
    cpp_module_scan_deps = action_config(
        action_name = ACTION_NAMES.cpp_module_deps_scanning,
        tools = [
            tool(
                path = deps_scanner,
            ),
        ],
        implies = compile_implies,
    )
    action_configs.append(cpp_module_scan_deps)

    cpp20_module_compile = action_config(
        action_name = ACTION_NAMES.cpp20_module_compile,
        tools = [
            tool(
                path = cc,
            ),
        ],
        flag_sets = [
            flag_set(
                flag_groups = [
                    flag_group(
                        flags = [
                            "-x",
                            "c++-module",
                        ],
                    ),
                ],
            ),
        ],
        implies = compile_implies,
    )
    action_configs.append(cpp20_module_compile)

    cpp20_module_codegen = action_config(
        action_name = ACTION_NAMES.cpp20_module_codegen,
        tools = [
            tool(
                path = cc,
            ),
        ],
        implies = compile_implies,
    )
    action_configs.append(cpp20_module_codegen)

    return action_configs

def _label_to_tool_path_feature(tool_mapping = {}):
    """Creates a feature with an env variable pointing to the label.

    Creates an always enabled feature that sets an environment variable in the
    format '<name:capitalised>_PATH'. This can then be used by the
    execution wrapper, which has to remain relative to the toolchain
    instantiation.

    Args:
        tool_mapping (Dict[str,File]): A mapping between the tool name and the
            executable file for that tool.
    """
    return feature(
        name = "__tool_paths_as_environment_vars",
        enabled = True,
        env_sets = [env_set(
            actions = ALL_ACTIONS,
            env_entries = [
                env_entry(name.upper().replace("-", "_") + "_PATH", file.path)
                for name, file in tool_mapping.items()
                if file
            ],
        )],
    )

def _create_artifact_name_patterns(ctx):
    artifact_name_patterns = []
    is_linux = ctx.attr.target_libc != "macosx"

    if is_linux:
        artifact_name_patterns += [
            artifact_name_pattern(
                category_name = "cpp_module",
                prefix = "",
                extension = ".pcm",
            ),
        ]
    else:
        artifact_name_patterns += [
            artifact_name_pattern(
                category_name = "dynamic_library",
                prefix = "lib",
                extension = ".dylib",
            ),
        ]

    return artifact_name_patterns

def _get_layering_features(extra_module_maps, extra_flags_per_feature = {}):
    """Returns features for layering check and header parsing."""

    extra_module_map_flags = [
        "-fmodule-map-file=" + file.path
        for label in extra_module_maps
        for file in label.files.to_list()
    ]

    return [
        feature(
            name = "module_map_home_cwd",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_header_parsing,
                        ACTION_NAMES.cpp_module_compile,
                    ],
                    flag_groups = [
                        flag_group(
                            flags = ["-Xclang=-fmodule-map-file-home-is-cwd"],
                        ),
                    ],
                ),
            ],
        ),
        feature(
            name = "use_module_maps",
            requires = [
              feature_set(
                features = [
                  "module_maps",
                ],
              ),
            ],
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_header_parsing,
                        ACTION_NAMES.cpp_module_compile,
                    ],
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-fmodule-name=%{module_name}",
                                "-fmodule-map-file=%{module_map_file}",
                            ] + extra_flags_per_feature.get("use_module_maps", []),
                        ),
                    ],
                ),
            ],
        ),
        feature(
            name = "module_maps",
            enabled = True,
            implies = [
              "module_map_home_cwd",
            ],
        ),
        feature(
            name = "layering_check",
            enabled = False,
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.c_compile,
                        ACTION_NAMES.cpp_compile,
                        ACTION_NAMES.cpp_header_parsing,
                        ACTION_NAMES.cpp_module_compile,
                    ],
                    flag_groups = [
                        flag_group(flags = [
                            "-fmodules-strict-decluse",
                            "-Wprivate-header",
                        ]),
                        # This list contains all of the module map dependencies
                        # that are known to Blaze.
                        flag_group(
                            flags = [
                                "-fmodule-map-file=%{dependent_module_map_files}",
                            ],
                            iterate_over = "dependent_module_map_files",
                        ),
                    ] + (
                        # This must appear after the dependent_module_map_files
                        # flags, because these files contain "crosstool.foo"
                        # modules that extend the "crosstool" module, and thus
                        # must appear after the file defining the top-level
                        # "crosstool" module.  That file is provided to the
                        # cc_toolchain rule as the "module_map" attribute, and
                        # thus appears in the dependent_module_map_files list.
                        [flag_group(flags = extra_module_map_flags)] if extra_module_map_flags else []
                    ),
                ),
            ],
            implies = ["use_module_maps"],
        ),
        feature(
            name = "parse_headers",
            flag_sets = [
                flag_set(
                    actions = [
                        ACTION_NAMES.cpp_header_parsing,
                    ],
                    flag_groups = [
                        flag_group(flags = [
                            "-xc++-header",
                            "-fsyntax-only",
                        ]),
                    ],
                ),
            ],
        ),
        feature(name = "compiler_param_file"),
        feature(name = "validates_layering_check_in_textual_hdrs", enabled = True),
    ]

def _cc_toolchain_config_impl(ctx):
    # Add system builtin include directories if specified
    builtin_include_dirs = ctx.attr.cxx_builtin_include_directories if ctx.attr.cxx_builtin_include_directories else []

    action_configs = _get_actions_config(ctx)
    features = [
        label[FeatureInfo]
        for label in ctx.attr.compiler_features
    ] + [_label_to_tool_path_feature({
        "gcc": ctx.file.c_compiler,
        "cpp": ctx.file.cc_compiler,
        "ld": ctx.file.linker,
        "ar": ctx.file.archiver,
        "strip": ctx.file.strip_tool,
        "cpp-module-deps-scanner": ctx.file.module_deps_scanner,
        "headers-parser": ctx.file.headers_parser,
        "in": ctx.file.install_name,
    })] + _get_layering_features({})

    parse_headers_action_configs, parse_headers_features = parse_headers_support(
        parse_headers_tool_path = ctx.file.headers_parser,
    )

    action_configs += parse_headers_action_configs
    features += parse_headers_features

    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        host_system_name = "local",
        target_system_name = ctx.attr.target_system_name,
        target_cpu = ctx.attr.target_cpu,
        target_libc = ctx.attr.target_libc,
        artifact_name_patterns = _create_artifact_name_patterns(ctx),
        toolchain_identifier = "aarch64_linux_clang_id",
        compiler = "clang",
        abi_version = "unknown",
        abi_libc_version = "unknown",
        cxx_builtin_include_directories = builtin_include_dirs,
        action_configs = action_configs,
        features = features,
        tool_paths = [
            tool_path(name = name, path = path)
            for name, path in ctx.attr.tool_paths.items()
        ],
    )

cc_toolchain_config = rule(
    implementation = _cc_toolchain_config_impl,
    attrs = {
        "target_system_name": attr.string(
            doc = "Target system name.",
            mandatory = True,
        ),
        "target_cpu": attr.string(
            doc = "Target CPU name.",
            mandatory = True,
        ),
        "target_libc": attr.string(
            doc = "Target libc.",
            mandatory = False,
            default = "unknown",
        ),
        "dynamic_library_extension": attr.string(
            doc = "Dynamic library extension.",
            mandatory = False,
            default = "",
        ),
        "tool_paths": attr.string_dict(
            default = {
                "gcc": "wrappers/clang",
                "cpp": "wrappers/clang++",
                "ld": "wrappers/ld",
                "ar": "wrappers/ar",
                "gcov": "wrappers/idler",
                "llvm-cov": "wrappers/idler",
                "nm": "wrappers/idler",
                "objdump": "wrappers/idler",
                "strip": "wrappers/strip",
                "cpp-module-deps-scanner": "wrappers/module-deps-scanner",
                "headers-parser": "wrappers/headers-parser",
            },
        ),
        "compiler_features": attr.label_list(
            providers = [FeatureInfo],
            doc = "A list of features that are used by the toolchain.",
            mandatory = True,
        ),
        "c_compiler": attr.label(
            doc = "The c compiler e.g. clang/gcc. Maps to tool path 'gcc'.",
            allow_single_file = True,
            mandatory = True,
        ),
        "cc_compiler": attr.label(
            doc = "The c++ compiler e.g. clang/gcc. Maps to tool path 'cpp'.",
            allow_single_file = True,
            mandatory = True,
        ),
        "linker": attr.label(
            doc = "The linker e.g. ld/lld. Maps to tool path 'ld'.",
            allow_single_file = True,
            mandatory = True,
        ),
        "archiver": attr.label(
            doc = "The archiver e.g. ar/llvm-ar. Maps to tool path 'ar'.",
            allow_single_file = True,
            mandatory = True,
        ),
        "cxx_builtin_include_directories": attr.string_list(
            doc = "List of builtin include directories for the toolchain. Needed for non-hermetic system includes.",
            default = [],
        ),
        "strip_tool": attr.label(
            doc = "The strip tool e.g. strip. Maps to tool path 'strip'.",
            allow_single_file = True,
        ),
        "module_deps_scanner": attr.label(
            doc = "The searching C++ modules tool.",
            allow_single_file = True,
            mandatory = False,
        ),
        "headers_parser": attr.label(
            doc = "The parsing headers tool.",
            allow_single_file = True,
            mandatory = False,
        ),
        "install_name": attr.label(
            doc = "The install name tool for macOS e.g. install_name_tool/llvm-install-name-tool. Maps to tool path 'nmt'.",
            allow_single_file = True,
            mandatory = False,
        ),
    },
    provides = [CcToolchainConfigInfo],
)
