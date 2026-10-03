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

"""Fortran toolchain definition and provider."""

load("@rules_cc//cc:action_names.bzl", "ACTION_NAMES")
load("@rules_cc//cc:defs.bzl", "CcInfo", "cc_common")
load("@rules_cc//cc:find_cc_toolchain.bzl", "find_cpp_toolchain")
load(
    "//fortran/features:features.bzl",
    "FortranFeatureInfo",
)
load(
    "//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl",
    "CcToolchainImportInfo",
)
load(
    "//third_party/rules_fortran/private:providers.bzl",
    _FortranToolchainInfo = "FortranToolchainInfo",
)

FortranToolchainInfo = _FortranToolchainInfo

# Flags in shared feature definitions that flang-new (-fc1) does not accept directly.
_FLANG_UNSUPPORTED_COMPILE_FLAGS = {
    "-nostdinc": True,
    "-nostdinc++": True,
    "-no-canonical-prefixes": True,
    "-Wno-builtin-macro-redefined": True,
}

# Flags supported by the flang-new driver starting in LLVM 20+.
_FLANG_LLVM20_PLUS_COMPILE_FLAGS = {
    "--no-default-config": True,
    "-fno-rtlib-add-rpath": True,
    "-nostdlib": True,
    "-nodefaultlibs": True,
}

def _filter_flang_compile_flags(flang_bin, flags):
    is_pre_llvm20 = flang_bin and ("llvm18" in flang_bin.path or "llvm19" in flang_bin.path)
    filtered = []
    for flag in flags:
        if flag in _FLANG_UNSUPPORTED_COMPILE_FLAGS:
            continue
        if is_pre_llvm20 and flag in _FLANG_LLVM20_PLUS_COMPILE_FLAGS:
            continue
        filtered.append(flag)
    return filtered

def _make_runtime_ccinfo(ctx, cc_toolchain, feature_configuration, runtime_libs):
    """Create CcInfo for Fortran runtime libraries."""
    if not runtime_libs:
        return CcInfo(
            compilation_context = cc_common.create_compilation_context(),
            linking_context = cc_common.create_linking_context(),
        )

    libraries_to_link = []
    for lib in runtime_libs:
        is_static = lib.extension in ["a", "lib", "lo", "o"]
        is_dynamic = lib.extension in ["so", "dylib", "dll"]

        library_to_link = cc_common.create_library_to_link(
            actions = ctx.actions,
            feature_configuration = feature_configuration,
            cc_toolchain = cc_toolchain,
            static_library = lib if is_static else None,
            pic_static_library = lib if is_static else None,
            dynamic_library = lib if is_dynamic else None,
        )
        libraries_to_link.append(library_to_link)

    linker_input = cc_common.create_linker_input(
        owner = ctx.label,
        libraries = depset(libraries_to_link, order = "topological"),
    )

    linking_context = cc_common.create_linking_context(
        linker_inputs = depset([linker_input], order = "topological"),
    )

    return CcInfo(
        compilation_context = cc_common.create_compilation_context(),
        linking_context = linking_context,
    )

def _fortran_toolchain_impl(ctx):
    flang_files = ctx.files.flang
    flang_bin = flang_files[0] if flang_files else None

    features = [f[FortranFeatureInfo] for f in ctx.attr.compiler_features]
    mode = ctx.var.get("COMPILATION_MODE", "fastbuild")

    enabled_names = {}
    for feature in features:
        if feature.name in ctx.disabled_features:
            continue
        if feature.expand_if_mode and feature.expand_if_mode != mode and feature.name not in ctx.features:
            continue
        if feature.enabled or feature.name in ctx.features:
            enabled_names[feature.name] = True
            for implied in feature.implies:
                if implied not in ctx.disabled_features:
                    enabled_names[implied] = True

    header_depsets = []
    intrinsic_dir_depsets = []
    include_dir_depsets = []
    if ctx.attr.flang_incs:
        flang_incs_info = ctx.attr.flang_incs[CcToolchainImportInfo]
        header_depsets.append(flang_incs_info.compilation_context.headers)
        intrinsic_dir_depsets.append(flang_incs_info.compilation_context.includes)

    sysroot_path = ctx.attr.sysroot.label.workspace_root if ctx.attr.sysroot else ""
    target = ctx.attr.target

    raw_compile_flags = []
    raw_linker_flags = []
    for feature in features:
        header_depsets.append(feature.headers)
        intrinsic_dir_depsets.append(feature.intrinsic_module_dirs)
        if feature.name in enabled_names:
            raw_compile_flags.extend(feature.compiler_flags)
            raw_linker_flags.extend(feature.linker_flags)
            include_dir_depsets.append(feature.include_dirs)
            if not sysroot_path and feature.sysroot:
                sysroot_path = feature.sysroot
            if not target and feature.target:
                target = feature.target

    raw_compile_flags.extend(ctx.attr.compiler_flags)
    raw_linker_flags.extend(ctx.attr.linker_flags)

    flang_headers = depset(transitive = header_depsets)
    flang_include_dirs = depset(transitive = intrinsic_dir_depsets)
    include_dirs = depset(transitive = include_dir_depsets)

    fortran_libs_info = ctx.attr.fortran_libs[CcToolchainImportInfo]
    fortran_libs = depset(
        transitive = [
            fortran_libs_info.linking_context.static_libraries,
            fortran_libs_info.linking_context.additional_libs,
        ],
        order = "topological",
    )

    fortran_main = depset(ctx.files.fortran_main)
    compiler_files = depset(
        direct = flang_files,
        transitive = [
            ctx.attr.compiler_files.files,
            flang_headers,
        ],
    )

    if "macosx" in target and hasattr(ctx.fragments, "apple"):
        macos_min_os = getattr(ctx.fragments.apple, "macos_minimum_os_flag", None)
        if macos_min_os:
            prefix = target.split("macosx")[0]
            target = "{}macosx{}".format(prefix, macos_min_os)

    filtered_flags = _filter_flang_compile_flags(flang_bin, raw_compile_flags)
    compiler_flags = []
    preprocessor_flags = list(ctx.attr.preprocessor_flags)

    if target:
        compiler_flags.append("--target=" + target)
    if sysroot_path:
        compiler_flags.append("--sysroot=" + sysroot_path)

    for flag in filtered_flags:
        if flag.startswith("-D"):
            # Escape double quotes for @file multiline response files
            preprocessor_flags.append(flag.replace('"', '\\"'))
        else:
            compiler_flags.append(flag)

    for mod_dir in flang_include_dirs.to_list():
        compiler_flags.append("-fintrinsic-modules-path")
        compiler_flags.append(mod_dir)
        compiler_flags.append("-I" + mod_dir)

    for inc_dir in include_dirs.to_list():
        compiler_flags.append("-I" + inc_dir)

    cc_toolchain = find_cpp_toolchain(ctx)
    cc_feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )

    link_variables = cc_common.create_link_variables(
        feature_configuration = cc_feature_configuration,
        cc_toolchain = cc_toolchain,
        is_using_linker = True,
        is_linking_dynamic_library = False,
    )
    cc_link_flags = cc_common.get_memory_inefficient_command_line(
        feature_configuration = cc_feature_configuration,
        action_name = ACTION_NAMES.cpp_link_executable,
        variables = link_variables,
    )

    linker_flags = []
    for flag in cc_link_flags:
        for part in flag.split(" "):
            if part:
                linker_flags.append(part)
    for flag in ctx.attr.linker_flags:
        for part in flag.split(" "):
            if part:
                linker_flags.append(part)

    archiver = ctx.file.archiver
    linker = ctx.file.linker
    if not archiver or not linker:
        for f in cc_toolchain.all_files.to_list():
            if not archiver and f.path.endswith("/bin/llvm-ar"):
                archiver = f
            elif not linker and f.path.endswith("/bin/clang++"):
                linker = f

    runtime_ccinfo = _make_runtime_ccinfo(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        feature_configuration = cc_feature_configuration,
        runtime_libs = fortran_libs.to_list(),
    )

    runtime_libraries = fortran_main.to_list() + fortran_libs.to_list()

    all_files = depset(
        direct = [f for f in [flang_bin, linker, archiver] if f],
        transitive = [
            compiler_files,
            fortran_libs,
            fortran_main,
            cc_toolchain.all_files,
        ],
    )

    toolchain_info = FortranToolchainInfo(
        compiler = flang_bin,
        linker = linker,
        archiver = archiver,
        compiler_flags = compiler_flags,
        linker_flags = linker_flags,
        preprocessor_flag = ctx.attr.preprocessor_flag,
        preprocessor_flags = preprocessor_flags,
        supports_module_path = ctx.attr.supports_module_path,
        module_flag_format = ctx.attr.module_flag_format,
        runtime_libraries = runtime_libraries,
        runtime_ccinfo = runtime_ccinfo,
        all_files = all_files,
    )

    return [
        platform_common.ToolchainInfo(
            fortran = toolchain_info,
            fortran_toolchain = toolchain_info,
        ),
        toolchain_info,
        DefaultInfo(
            files = all_files,
        ),
    ]

fortran_toolchain = rule(
    implementation = _fortran_toolchain_impl,
    fragments = ["apple", "cpp"],
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"],
    attrs = {
        "flang": attr.label(
            doc = "The flang-new compiler binary target.",
            allow_files = True,
            cfg = "exec",
            mandatory = True,
        ),
        "archiver": attr.label(
            doc = "Optional archiver executable (defaults to llvm-ar from the C++ toolchain).",
            allow_single_file = True,
            cfg = "exec",
        ),
        "linker": attr.label(
            doc = "Optional linker executable (defaults to clang++ from the C++ toolchain).",
            allow_single_file = True,
            cfg = "exec",
        ),
        "compiler_files": attr.label(
            doc = "Files required by the Fortran compiler at execution time.",
            allow_files = True,
            cfg = "exec",
            mandatory = True,
        ),
        "compiler_features": attr.label_list(
            doc = "List of FortranFeatureInfo targets configuring compiler/linker flags, imports, and sysroot.",
            providers = [FortranFeatureInfo],
            default = [],
        ),
        "flang_incs": attr.label(
            doc = "Built-in Fortran intrinsic modules and headers.",
            providers = [CcToolchainImportInfo],
        ),
        "fortran_libs": attr.label(
            doc = "Fortran runtime static libraries.",
            providers = [CcToolchainImportInfo],
            mandatory = True,
        ),
        "fortran_main": attr.label(
            doc = "Fortran main entry-point library (if applicable for the LLVM version).",
            allow_files = True,
            mandatory = True,
        ),
        "sysroot": attr.label(
            doc = "Target sysroot package (can also be supplied via compiler_features).",
        ),
        "target": attr.string(
            doc = "Target triple (e.g. x86_64-linux-gnu; can also be supplied via compiler_features).",
            default = "",
        ),
        "target_cpu": attr.string(
            doc = "Target CPU name (e.g. x86_64, aarch64).",
            mandatory = True,
        ),
        "compiler_flags": attr.string_list(
            doc = "Default flags passed to flang during compilation.",
            default = [],
        ),
        "linker_flags": attr.string_list(
            doc = "Default flags passed during linking.",
            default = [],
        ),
        "module_flag_format": attr.string(
            doc = "Format string for module path flag. Use {} as placeholder for path.",
            default = "-J{}",
        ),
        "preprocessor_flag": attr.string(
            doc = "Flag to enable preprocessing (e.g., '-cpp' for gfortran/flang, '-fpp' for ifort).",
            default = "-cpp",
        ),
        "preprocessor_flags": attr.string_list(
            doc = "Default preprocessor flags (e.g., ['-D_OPENMP', '-DUSE_MPI']).",
            default = [],
        ),
        "supports_module_path": attr.bool(
            doc = "Whether the compiler supports specifying module output directory.",
            default = True,
        ),
        "toolchain_identifier": attr.string(
            doc = "Toolchain identifier.",
            default = "",
        ),
        "_cc_toolchain": attr.label(
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
        ),
    },
    provides = [platform_common.ToolchainInfo],
)
