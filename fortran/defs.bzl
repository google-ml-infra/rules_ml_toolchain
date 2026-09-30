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

"""Public Starlark rules and providers for building Fortran targets."""

load("@rules_cc//cc:defs.bzl", "CcInfo", "cc_common")
load("@rules_cc//cc:find_cc_toolchain.bzl", "find_cpp_toolchain")
load(
    "//fortran:toolchain.bzl",
    _FortranToolchainInfo = "FortranToolchainInfo",
    _fortran_toolchain = "fortran_toolchain",
)

FortranToolchainInfo = _FortranToolchainInfo
fortran_toolchain = _fortran_toolchain

FortranInfo = provider(
    doc = "Provider carrying Fortran module directories (.mod) and transitive Fortran sources.",
    fields = {
        "module_dirs": "depset of File (TreeArtifact directories): Directories containing compiled .mod files.",
        "transitive_sources": "depset of File: Transitive Fortran source files.",
    },
)

FORTRAN_EXTENSIONS = [
    "f",
    "f90",
    "f95",
    "f03",
    "f08",
    "for",
    "ftn",
    "F",
    "F90",
    "F95",
    "F03",
    "F08",
    "FOR",
    "FTN",
]

def _normalise_include(ctx, inc):
    root_str = ""
    if ctx.label.workspace_root:
        root_str = ctx.label.workspace_root + "/"
    package_str = ""
    if ctx.label.package:
        package_str = ctx.label.package + "/"
    if inc == "." or inc == "":
        return (root_str + package_str).rstrip("/")
    return root_str + package_str + inc

def _compilation_mode_flags(ctx):
    mode = ctx.var.get("COMPILATION_MODE", "fastbuild")
    if mode == "dbg":
        return ["-g", "-O0"]
    elif mode == "opt":
        return ["-g0", "-O2", "-DNDEBUG"]
    return ["-O0"]

def _collect_deps(deps):
    cc_compilation_contexts = []
    cc_linking_contexts = []
    fortran_mod_dirs = []
    fortran_sources = []

    for dep in deps:
        if CcInfo in dep:
            cc_compilation_contexts.append(dep[CcInfo].compilation_context)
            cc_linking_contexts.append(dep[CcInfo].linking_context)
        if FortranInfo in dep:
            fortran_mod_dirs.append(dep[FortranInfo].module_dirs)
            fortran_sources.append(dep[FortranInfo].transitive_sources)

    return (
        cc_compilation_contexts,
        cc_linking_contexts,
        depset(transitive = fortran_mod_dirs, order = "topological"),
        depset(transitive = fortran_sources, order = "topological"),
    )

def _compile_fortran_sources(
        ctx,
        fortran_toolchain,
        cc_compilation_context,
        dep_mod_dirs):
    srcs = [f for f in ctx.files.srcs if f.extension in FORTRAN_EXTENSIONS]
    if not srcs:
        return [], []

    if not fortran_toolchain.flang:
        fail("Fortran compiler (flang-new) is not available in the configured LLVM toolchain for target {}.".format(ctx.label))

    objects = []
    local_mod_dirs = []
    mode_flags = _compilation_mode_flags(ctx)

    for idx, src in enumerate(srcs):
        stem = src.basename[:-len(src.extension) - 1] if src.extension else src.basename
        obj = ctx.actions.declare_file("_fortran_objs/{}/{}_{}.pic.o".format(ctx.label.name, idx, stem))
        mod_dir = ctx.actions.declare_directory("_fortran_mods/{}/{}_{}".format(ctx.label.name, idx, stem))

        args = ctx.actions.args()
        args.add("--target=" + fortran_toolchain.target)
        if fortran_toolchain.sysroot_path:
            args.add("--sysroot=" + fortran_toolchain.sysroot_path)

        args.add("-fPIC")
        args.add_all(mode_flags)
        args.add_all(fortran_toolchain.compiler_flags)

        # Built-in Fortran intrinsic module directories (iso_c_binding, iso_fortran_env, etc.)
        args.add_all(fortran_toolchain.flang_include_dirs, format_each = "-I%s")

        # C/C++ preprocessor defines and include paths for .F/.F90 preprocessed files
        args.add_all(cc_compilation_context.defines, format_each = "-D%s")
        args.add_all(cc_compilation_context.local_defines, format_each = "-D%s")
        args.add_all(ctx.attr.defines, format_each = "-D%s")
        args.add_all(cc_compilation_context.includes, format_each = "-I%s")
        args.add_all(cc_compilation_context.quote_includes, format_each = "-I%s")
        args.add_all(cc_compilation_context.system_includes, format_each = "-I%s")

        # Transitive and intra-target Fortran .mod directories
        args.add_all(dep_mod_dirs, format_each = "-I%s", expand_directories = False)
        args.add_all(local_mod_dirs, format_each = "-I%s", expand_directories = False)

        # Output directory for .mod files produced by this compilation unit
        args.add("-J" + mod_dir.path)

        # User-provided compiler options
        args.add_all(ctx.attr.copts)
        args.add_all(ctx.attr.fopts)

        args.add("-c", src)
        args.add("-o", obj)

        inputs = depset(
            direct = [src] + getattr(ctx.files, "hdrs", []) + local_mod_dirs,
            transitive = [
                fortran_toolchain.compiler_files,
                fortran_toolchain.flang_headers,
                cc_compilation_context.headers,
                dep_mod_dirs,
            ],
        )

        ctx.actions.run(
            mnemonic = "FortranCompile",
            progress_message = "Compiling Fortran {}".format(src.short_path),
            executable = fortran_toolchain.flang,
            arguments = [args],
            inputs = inputs,
            outputs = [obj, mod_dir],
        )

        objects.append(obj)
        local_mod_dirs.append(mod_dir)

    return objects, local_mod_dirs

def _create_static_libs_linking_context(ctx, cc_toolchain, feature_configuration, libs):
    static_libs = [lib for lib in libs if lib.extension in ["a", "lo", "o"]]
    if not static_libs:
        return None

    libraries_to_link = [
        cc_common.create_library_to_link(
            actions = ctx.actions,
            feature_configuration = feature_configuration,
            cc_toolchain = cc_toolchain,
            static_library = lib,
            pic_static_library = lib,
            alwayslink = False,
        )
        for lib in static_libs
    ]
    linker_input = cc_common.create_linker_input(
        owner = ctx.label,
        libraries = depset(libraries_to_link, order = "topological"),
    )
    return cc_common.create_linking_context(
        linker_inputs = depset([linker_input], order = "topological"),
    )

def _collect_runfiles(ctx, extra_files = []):
    runfiles = ctx.runfiles(files = extra_files + ctx.files.data)
    transitive = []
    for dep in ctx.attr.deps + ctx.attr.data:
        transitive.append(dep[DefaultInfo].default_runfiles)
    return runfiles.merge_all(transitive)

def _fortran_library_impl(ctx):
    fortran_toolchain = ctx.toolchains["//fortran:toolchain_type"].fortran_toolchain
    cc_toolchain = find_cpp_toolchain(ctx)
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )

    (
        dep_compilation_contexts,
        dep_linking_contexts,
        dep_mod_dirs,
        dep_fortran_sources,
    ) = _collect_deps(ctx.attr.deps)

    local_includes = [_normalise_include(ctx, inc) for inc in ctx.attr.includes]
    self_compilation_context = cc_common.create_compilation_context(
        headers = depset(
            direct = ctx.files.hdrs,
            transitive = [fortran_toolchain.flang_headers],
        ),
        includes = depset(local_includes),
        system_includes = fortran_toolchain.flang_include_dirs,
        defines = depset(ctx.attr.defines),
    )
    merged_compilation_context = cc_common.merge_compilation_contexts(
        compilation_contexts = [self_compilation_context] + dep_compilation_contexts,
    )

    objects, local_mod_dirs = _compile_fortran_sources(
        ctx = ctx,
        fortran_toolchain = fortran_toolchain,
        cc_compilation_context = merged_compilation_context,
        dep_mod_dirs = dep_mod_dirs,
    )

    compilation_outputs = cc_common.create_compilation_outputs(
        objects = depset(objects),
        pic_objects = depset(objects),
    )

    runtime_linking_context = _create_static_libs_linking_context(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        feature_configuration = feature_configuration,
        libs = fortran_toolchain.fortran_libs.to_list(),
    )

    linking_contexts = list(dep_linking_contexts)
    if runtime_linking_context:
        linking_contexts.append(runtime_linking_context)

    if objects:
        linking_context, linking_outputs = cc_common.create_linking_context_from_compilation_outputs(
            actions = ctx.actions,
            feature_configuration = feature_configuration,
            cc_toolchain = cc_toolchain,
            compilation_outputs = compilation_outputs,
            user_link_flags = fortran_toolchain.linker_flags + ctx.attr.linkopts,
            linking_contexts = linking_contexts,
            name = ctx.label.name,
            alwayslink = ctx.attr.alwayslink,
            disallow_dynamic_library = True,
        )
        output_files = []
        if linking_outputs.library_to_link:
            if linking_outputs.library_to_link.static_library:
                output_files.append(linking_outputs.library_to_link.static_library)
            if linking_outputs.library_to_link.pic_static_library:
                output_files.append(linking_outputs.library_to_link.pic_static_library)
    else:
        user_linker_input = cc_common.create_linker_input(
            owner = ctx.label,
            user_link_flags = depset(fortran_toolchain.linker_flags + ctx.attr.linkopts),
        )
        self_linking_context = cc_common.create_linking_context(
            linker_inputs = depset([user_linker_input]),
        )
        linking_context = cc_common.merge_linking_contexts(
            linking_contexts = [self_linking_context] + linking_contexts,
        )
        output_files = []

    merged_mod_dirs = depset(
        direct = local_mod_dirs,
        transitive = [dep_mod_dirs],
        order = "topological",
    )
    merged_sources = depset(
        direct = ctx.files.srcs,
        transitive = [dep_fortran_sources],
        order = "topological",
    )

    return [
        DefaultInfo(
            files = depset(output_files + local_mod_dirs),
            runfiles = _collect_runfiles(ctx),
        ),
        CcInfo(
            compilation_context = merged_compilation_context,
            linking_context = linking_context,
        ),
        FortranInfo(
            module_dirs = merged_mod_dirs,
            transitive_sources = merged_sources,
        ),
    ]

def _fortran_binary_or_test_impl(ctx):
    fortran_toolchain = ctx.toolchains["//fortran:toolchain_type"].fortran_toolchain
    cc_toolchain = find_cpp_toolchain(ctx)
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )

    (
        dep_compilation_contexts,
        dep_linking_contexts,
        dep_mod_dirs,
        dep_fortran_sources,
    ) = _collect_deps(ctx.attr.deps)

    self_compilation_context = cc_common.create_compilation_context(
        headers = fortran_toolchain.flang_headers,
        system_includes = fortran_toolchain.flang_include_dirs,
        defines = depset(ctx.attr.defines),
    )
    merged_compilation_context = cc_common.merge_compilation_contexts(
        compilation_contexts = [self_compilation_context] + dep_compilation_contexts,
    )

    objects, local_mod_dirs = _compile_fortran_sources(
        ctx = ctx,
        fortran_toolchain = fortran_toolchain,
        cc_compilation_context = merged_compilation_context,
        dep_mod_dirs = dep_mod_dirs,
    )

    compilation_outputs = cc_common.create_compilation_outputs(
        objects = depset(objects),
        pic_objects = depset(objects),
    )

    main_linking_context = _create_static_libs_linking_context(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        feature_configuration = feature_configuration,
        libs = fortran_toolchain.fortran_main.to_list(),
    )
    runtime_linking_context = _create_static_libs_linking_context(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        feature_configuration = feature_configuration,
        libs = fortran_toolchain.fortran_libs.to_list(),
    )

    linking_contexts = list(dep_linking_contexts)
    if main_linking_context:
        linking_contexts.append(main_linking_context)
    if runtime_linking_context:
        linking_contexts.append(runtime_linking_context)

    linkshared = getattr(ctx.attr, "linkshared", False)
    linking_outputs = cc_common.link(
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        compilation_outputs = compilation_outputs,
        user_link_flags = fortran_toolchain.linker_flags + ctx.attr.linkopts,
        linking_contexts = linking_contexts,
        name = ctx.label.name,
        output_type = "dynamic_library" if linkshared else "executable",
        link_deps_statically = ctx.attr.linkstatic,
    )

    executable = linking_outputs.executable if not linkshared else linking_outputs.library_to_link.resolved_symlink_dynamic_library
    output_files = [executable] if executable else []

    merged_mod_dirs = depset(
        direct = local_mod_dirs,
        transitive = [dep_mod_dirs],
        order = "topological",
    )
    merged_sources = depset(
        direct = ctx.files.srcs,
        transitive = [dep_fortran_sources],
        order = "topological",
    )

    return [
        DefaultInfo(
            executable = executable if not linkshared else None,
            files = depset(output_files),
            runfiles = _collect_runfiles(ctx, output_files),
        ),
        FortranInfo(
            module_dirs = merged_mod_dirs,
            transitive_sources = merged_sources,
        ),
    ]

_COMMON_ATTRS = {
    "srcs": attr.label_list(
        doc = "Fortran source files (.f, .f90, .f95, .f03, .f08, .F, .F90, etc.).",
        allow_files = ["." + ext for ext in FORTRAN_EXTENSIONS] + [".h", ".inc"],
        default = [],
    ),
    "deps": attr.label_list(
        doc = "Dependencies providing FortranInfo and/or CcInfo (e.g. fortran_library, cc_library).",
        providers = [[CcInfo], [FortranInfo]],
        default = [],
    ),
    "data": attr.label_list(
        doc = "Files needed by this target at runtime.",
        allow_files = True,
        default = [],
    ),
    "copts": attr.string_list(
        doc = "Additional compiler flags passed to flang.",
        default = [],
    ),
    "fopts": attr.string_list(
        doc = "Additional Fortran-specific compiler flags passed to flang.",
        default = [],
    ),
    "defines": attr.string_list(
        doc = "Preprocessor defines (-D) passed when compiling.",
        default = [],
    ),
    "linkopts": attr.string_list(
        doc = "Additional linker flags.",
        default = [],
    ),
    "linkstatic": attr.bool(
        doc = "Link dependencies statically.",
        default = True,
    ),
    "_cc_toolchain": attr.label(
        default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
    ),
}

_LIBRARY_ATTRS = dict(_COMMON_ATTRS)
_LIBRARY_ATTRS.update({
    "hdrs": attr.label_list(
        doc = "C/C++ or Fortran header files exported by this library for C/C++ or Fortran interoperability.",
        allow_files = [".h", ".hh", ".hpp", ".inc"],
        default = [],
    ),
    "includes": attr.string_list(
        doc = "Include directories to export to dependent targets.",
        default = [],
    ),
    "alwayslink": attr.bool(
        doc = "If True, link all symbols from this library into dependents (--whole-archive).",
        default = False,
    ),
})

_BINARY_ATTRS = dict(_COMMON_ATTRS)
_BINARY_ATTRS.update({
    "linkshared": attr.bool(
        doc = "Create a shared library (.so/.dylib) instead of an executable.",
        default = False,
    ),
})

fortran_library = rule(
    implementation = _fortran_library_impl,
    attrs = _LIBRARY_ATTRS,
    fragments = ["cpp"],
    toolchains = [
        "//fortran:toolchain_type",
        "@bazel_tools//tools/cpp:toolchain_type",
    ],
    provides = [CcInfo, FortranInfo],
    doc = "Compiles Fortran source files into a library providing both FortranInfo (.mod files) and CcInfo.",
)

fortran_binary = rule(
    implementation = _fortran_binary_or_test_impl,
    attrs = _BINARY_ATTRS,
    executable = True,
    fragments = ["cpp"],
    toolchains = [
        "//fortran:toolchain_type",
        "@bazel_tools//tools/cpp:toolchain_type",
    ],
    doc = "Compiles and links a Fortran executable or shared library.",
)

fortran_test = rule(
    implementation = _fortran_binary_or_test_impl,
    attrs = _COMMON_ATTRS,
    test = True,
    fragments = ["cpp"],
    toolchains = [
        "//fortran:toolchain_type",
        "@bazel_tools//tools/cpp:toolchain_type",
    ],
    doc = "Compiles and links a Fortran test executable.",
)
