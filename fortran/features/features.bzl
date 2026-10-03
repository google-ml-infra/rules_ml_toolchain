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

"""Feature rules and providers for the hermetic Fortran toolchain."""

load(
    "//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl",
    "CcToolchainImportInfo",
)

FortranFeatureInfo = provider(
    doc = "Provider representing a configurable Fortran toolchain feature.",
    fields = {
        "name": "str: Name of the feature.",
        "enabled": "bool: Whether the feature is enabled by default.",
        "provides": "list of str: Mutex capability keys provided by this feature.",
        "implies": "list of str: Feature names automatically enabled by this feature.",
        "compiler_flags": "list of str: Flags passed to flang during compilation.",
        "linker_flags": "list of str: Flags passed during linking.",
        "env_sets": "dict of str to str: Environment variables set for compilation.",
        "expand_if_mode": "str: Optional compilation mode (fastbuild, dbg, opt) required to expand this feature.",
        "include_dirs": "depset of str: System/toolchain include directories.",
        "intrinsic_module_dirs": "depset of str: Fortran intrinsic module directories (-fintrinsic-modules-path).",
        "headers": "depset of File: Headers and module files provided by this feature.",
        "sysroot": "str: Target sysroot path if provided by this feature.",
        "target": "str: Target triple if provided by this feature.",
    },
)

def _fortran_feature_impl(ctx):
    return [
        FortranFeatureInfo(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            provides = ctx.attr.provides,
            implies = [target.label.name for target in ctx.attr.implies],
            compiler_flags = ctx.attr.compiler_flags,
            linker_flags = ctx.attr.linker_flags,
            env_sets = ctx.attr.env_sets,
            expand_if_mode = ctx.attr.expand_if_mode,
            include_dirs = depset(),
            intrinsic_module_dirs = depset(),
            headers = depset(),
            sysroot = "",
            target = "",
        ),
    ]

fortran_feature = rule(
    implementation = _fortran_feature_impl,
    attrs = {
        "enabled": attr.bool(
            default = False,
            doc = "Whether this feature is enabled by default.",
        ),
        "provides": attr.string_list(
            default = [],
            doc = "Unique key for which only one provider can be enabled at a time.",
        ),
        "implies": attr.label_list(
            default = [],
            providers = [FortranFeatureInfo],
            doc = "Other features automatically enabled with this feature.",
        ),
        "compiler_flags": attr.string_list(
            default = [],
            doc = "Flags passed to flang during compilation.",
        ),
        "linker_flags": attr.string_list(
            default = [],
            doc = "Flags passed during linking.",
        ),
        "env_sets": attr.string_dict(
            default = {},
            doc = "Environment variables applied during compilation.",
        ),
        "expand_if_mode": attr.string(
            default = "",
            doc = "Compilation mode (fastbuild, dbg, opt) required for this feature.",
        ),
    },
    provides = [FortranFeatureInfo],
)

def _fortran_toolchain_import_feature_impl(ctx):
    toolchain_import_info = ctx.attr.toolchain_import[CcToolchainImportInfo]
    include_dirs = toolchain_import_info.compilation_context.includes
    headers = toolchain_import_info.compilation_context.headers

    intrinsic_module_dirs = depset()
    if ctx.attr.flang_incs:
        flang_incs_info = ctx.attr.flang_incs[CcToolchainImportInfo]
        intrinsic_module_dirs = flang_incs_info.compilation_context.includes
        headers = depset(
            transitive = [
                headers,
                flang_incs_info.compilation_context.headers,
            ],
        )

    return [
        FortranFeatureInfo(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            provides = ctx.attr.provides,
            implies = [target.label.name for target in ctx.attr.implies],
            compiler_flags = [],
            linker_flags = [],
            env_sets = {},
            expand_if_mode = "",
            include_dirs = include_dirs,
            intrinsic_module_dirs = intrinsic_module_dirs,
            headers = headers,
            sysroot = "",
            target = "",
        ),
        ctx.attr.toolchain_import[DefaultInfo],
    ]

fortran_toolchain_import_feature = rule(
    implementation = _fortran_toolchain_import_feature_impl,
    attrs = {
        "enabled": attr.bool(default = False),
        "provides": attr.string_list(default = []),
        "implies": attr.label_list(default = [], providers = [FortranFeatureInfo]),
        "toolchain_import": attr.label(
            mandatory = True,
            providers = [CcToolchainImportInfo],
        ),
        "flang_incs": attr.label(
            providers = [CcToolchainImportInfo],
            doc = "Optional label to flang_incs target providing intrinsic Fortran .mod files.",
        ),
    },
    provides = [FortranFeatureInfo, DefaultInfo],
)

def _fortran_sysroot_feature_impl(ctx):
    target = ctx.attr.target
    if "macosx" in target and hasattr(ctx.fragments, "apple"):
        macos_min_os = getattr(ctx.fragments.apple, "macos_minimum_os_flag", None)
        if macos_min_os:
            prefix = target.split("macosx")[0]
            target = "{}macosx{}".format(prefix, macos_min_os)

    sysroot_path = ctx.attr.sysroot.label.workspace_root

    return [
        FortranFeatureInfo(
            name = ctx.label.name,
            enabled = ctx.attr.enabled,
            provides = ctx.attr.provides,
            implies = [label.label.name for label in ctx.attr.implies],
            compiler_flags = [],
            linker_flags = [],
            env_sets = {},
            expand_if_mode = "",
            include_dirs = depset(),
            intrinsic_module_dirs = depset(),
            headers = depset(),
            sysroot = sysroot_path,
            target = target,
        ),
    ]

fortran_toolchain_sysroot_feature = rule(
    implementation = _fortran_sysroot_feature_impl,
    fragments = ["apple"],
    attrs = {
        "enabled": attr.bool(default = False),
        "provides": attr.string_list(default = []),
        "implies": attr.label_list(default = [], providers = [FortranFeatureInfo]),
        "sysroot": attr.label(mandatory = True),
        "target": attr.string(mandatory = True),
    },
    provides = [FortranFeatureInfo],
)
