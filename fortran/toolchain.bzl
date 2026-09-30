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

load(
    "//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl",
    "CcToolchainImportInfo",
)

FortranToolchainInfo = provider(
    doc = "Information about the hermetic LLVM Flang Fortran toolchain.",
    fields = {
        "flang": "File (or None): The flang-new compiler executable.",
        "compiler_files": "depset of File: All files needed by the Fortran compiler at execution time.",
        "flang_headers": "depset of File: Built-in Fortran module files (.mod) and headers (e.g. ISO_Fortran_binding.h).",
        "flang_include_dirs": "depset of str: Include directories for built-in Fortran modules and headers.",
        "fortran_libs": "depset of File: Fortran runtime static libraries (libFortranRuntime.a / libflang_rt.runtime.a, libFortranDecimal.a).",
        "fortran_main": "depset of File: Fortran program entry-point library (libFortran_main.a when required by LLVM version).",
        "sysroot_path": "str: Path to the target sysroot directory.",
        "target": "str: Target triple passed to flang via --target=.",
        "target_cpu": "str: Target CPU architecture.",
        "compiler_flags": "list of str: Default Fortran compiler flags.",
        "linker_flags": "list of str: Default Fortran linker flags.",
        "toolchain_identifier": "str: Unique identifier for the toolchain.",
    },
)

def _fortran_toolchain_impl(ctx):
    flang_files = ctx.files.flang
    flang_bin = flang_files[0] if flang_files else None

    flang_incs_info = ctx.attr.flang_incs[CcToolchainImportInfo]
    flang_headers = flang_incs_info.compilation_context.headers
    flang_include_dirs = flang_incs_info.compilation_context.includes

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

    sysroot_path = ctx.attr.sysroot.label.workspace_root

    fortran_toolchain_info = FortranToolchainInfo(
        flang = flang_bin,
        compiler_files = compiler_files,
        flang_headers = flang_headers,
        flang_include_dirs = flang_include_dirs,
        fortran_libs = fortran_libs,
        fortran_main = fortran_main,
        sysroot_path = sysroot_path,
        target = ctx.attr.target,
        target_cpu = ctx.attr.target_cpu,
        compiler_flags = ctx.attr.compiler_flags,
        linker_flags = ctx.attr.linker_flags,
        toolchain_identifier = ctx.attr.toolchain_identifier,
    )

    all_files = depset(
        transitive = [
            compiler_files,
            fortran_libs,
            fortran_main,
        ],
    )

    return [
        platform_common.ToolchainInfo(
            fortran_toolchain = fortran_toolchain_info,
        ),
        DefaultInfo(
            files = all_files,
        ),
    ]

fortran_toolchain = rule(
    implementation = _fortran_toolchain_impl,
    attrs = {
        "flang": attr.label(
            doc = "The flang-new compiler binary target.",
            allow_files = True,
            cfg = "exec",
            mandatory = True,
        ),
        "compiler_files": attr.label(
            doc = "Files required by the Fortran compiler at execution time.",
            allow_files = True,
            cfg = "exec",
            mandatory = True,
        ),
        "flang_incs": attr.label(
            doc = "Built-in Fortran intrinsic modules and headers.",
            providers = [CcToolchainImportInfo],
            mandatory = True,
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
            doc = "Target sysroot package.",
            mandatory = True,
        ),
        "target": attr.string(
            doc = "Target triple (e.g. x86_64-linux-gnu).",
            mandatory = True,
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
        "toolchain_identifier": attr.string(
            doc = "Toolchain identifier.",
            default = "",
        ),
    },
    provides = [platform_common.ToolchainInfo],
)
