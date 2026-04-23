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

"""ROCm compilation rule that uses hipcc directly and reads flags from toolchain."""

load("@config_rocm_hipcc//rocm:build_defs.bzl", "hipcc_config")
load("//cc/rocm:rocm_flags_provider.bzl", "RocmFlagsInfo")

def _rocm_compile_impl(ctx):
    """Compiles ROCm sources using hipcc directly with flags from ROCm toolchain."""

    # Get ROCm compiler flags from the provider (not from hermetic clang toolchain)
    rocm_flags = ctx.attr._rocm_flags[RocmFlagsInfo]

    # Collect compilation contexts from dependencies
    cc_infos = [dep[CcInfo] for dep in ctx.attr.deps if CcInfo in dep]
    compilation_contexts = [cc_info.compilation_context for cc_info in cc_infos]

    # Merge compilation context from dependencies
    merged_compilation_context = cc_common.merge_compilation_contexts(
        compilation_contexts = compilation_contexts,
    )

    # Find the ROCm root path in the sandbox by looking for rocm_dist directory
    # The files are staged as external/config_rocm_hipcc/rocm/rocm_dist/...
    rocm_sandbox_path = None
    for file in ctx.files._rocm_root:
        # Find a file and extract the rocm_dist directory path
        # file.path looks like: external/config_rocm_hipcc/rocm/rocm_dist/...
        if "rocm_dist" in file.path:
            parts = file.path.split("rocm_dist")
            if len(parts) >= 2:
                rocm_sandbox_path = parts[0] + "rocm_dist"
                break

    if not rocm_sandbox_path:
        fail("Could not determine ROCm sandbox path from _rocm_root files")

    # Compile each source file
    objects = []
    for src in ctx.files.srcs:
        obj = ctx.actions.declare_file(src.basename + ".pic.o")

        # Build compilation command for hipcc
        args = ctx.actions.args()
        args.add("-x", "hip")  # Use standard HIP language mode
        args.add("-c")

        # Add all ROCm toolchain flags (from ROCm features, not hermetic clang)
        args.add_all(rocm_flags.compiler_flags)

        # Add --rocm-path with actual sandbox path
        args.add("--rocm-path=" + rocm_sandbox_path)

        # Add user-specified compile options
        args.add_all(ctx.attr.copts)

        # Add include paths from dependencies
        args.add_all(merged_compilation_context.includes, before_each = "-I")
        args.add_all(merged_compilation_context.quote_includes, before_each = "-iquote")
        args.add_all(merged_compilation_context.system_includes, before_each = "-isystem")

        # Add defines from dependencies
        args.add_all(merged_compilation_context.defines, format_each = "-D%s")

        # Add source and output
        args.add(src)
        args.add("-o", obj)

        # Set environment for hipcc
        # ROCM_PATH: tells hipcc where ROCm installation is (includes clang++ in lib/llvm/bin/)
        # hipcc will use clang++ from the ROCm distribution (already in toolchain_data)
        env = {
            "ROCM_PATH": rocm_sandbox_path,
        }

        ctx.actions.run(
            executable = ctx.executable._hipcc,
            arguments = [args],
            inputs = depset(
                direct = [src] + ctx.files.hdrs,
                transitive = [
                    merged_compilation_context.headers,
                    depset(ctx.files._rocm_root),
                    depset(ctx.files._rocm_toolchain_data),  # Includes ROCm's clang++ and all LLVM tools
                ],
            ),
            outputs = [obj],
            env = env,
            mnemonic = "RocmCompile",
        )

        objects.append(obj)

    return [DefaultInfo(files = depset(objects))]

rocm_compile = rule(
    implementation = _rocm_compile_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".cu.cc", ".cc"],
            mandatory = True,
        ),
        "hdrs": attr.label_list(
            allow_files = [".h", ".cu.h"],
        ),
        "deps": attr.label_list(
            providers = [CcInfo],
        ),
        "copts": attr.string_list(),
        "_hipcc": attr.label(
            default = "@config_rocm_hipcc//rocm:hipcc",
            executable = True,
            cfg = "exec",
        ),
        "_rocm_root": attr.label(
            default = "@config_rocm_hipcc//rocm:rocm_root",
            allow_files = True,
        ),
        "_rocm_toolchain_data": attr.label(
            default = "@config_rocm_hipcc//rocm:toolchain_data",
            allow_files = True,
        ),
        "_rocm_flags": attr.label(
            default = "@rules_ml_toolchain//cc/rocm:rocm_flags",
            providers = [RocmFlagsInfo],
        ),
    },
)
