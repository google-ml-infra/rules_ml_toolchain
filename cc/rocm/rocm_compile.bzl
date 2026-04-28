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

"""ROCm compilation rule that compiles GPU code into .o files for linking into the final binary."""

def _rocm_compile_impl(ctx):
    """Compiles ROCm sources into .pic.o files with embedded GPU kernels (fat binaries)."""

    # Get the ROCm toolchain provided as an attribute
    cc_toolchain = ctx.attr._cc_toolchain[cc_common.CcToolchainInfo]

    # Collect compilation contexts from dependencies
    cc_infos = [dep[CcInfo] for dep in ctx.attr.deps if CcInfo in dep]
    compilation_contexts = [cc_info.compilation_context for cc_info in cc_infos]

    # Merge compilation context from dependencies
    merged_compilation_context = cc_common.merge_compilation_contexts(
        compilation_contexts = compilation_contexts,
    )

    # Get feature configuration from toolchain
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )

    # Get compiler flags from features
    compile_variables = cc_common.create_compile_variables(
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        user_compile_flags = ctx.attr.copts,
    )
    compiler_flags = cc_common.get_memory_inefficient_command_line(
        feature_configuration = feature_configuration,
        action_name = "c++-compile",
        variables = compile_variables,
    )

    # Get environment variables from feature configuration
    # These include HIPCC_PATH, ROCM_PATH, etc. set by rocm_hipcc_feature
    env_vars = cc_common.get_environment_variables(
        feature_configuration = feature_configuration,
        action_name = "c++-compile",
        variables = compile_variables,
    )

    # Use hipcc executable from toolchain
    hipcc_files = ctx.files._hipcc
    if len(hipcc_files) != 1:
        fail("Expected exactly one hipcc file, got: %s" % hipcc_files)
    hipcc_file = hipcc_files[0]

    # Compile each source file
    objects = []
    for src in ctx.files.srcs:
        # Use target-specific directory to avoid conflicts when same source compiled with different defines
        obj = ctx.actions.declare_file("_objs/" + ctx.label.name + "/" + src.basename + ".pic.o")

        # Build compilation command for hipcc
        args = ctx.actions.args()
        args.add("-x", "hip")  # Use standard HIP language mode
        args.add("-c")

        # Add compiler flags from toolchain features
        args.add_all(compiler_flags)

        # Add include paths from dependencies
        args.add_all(merged_compilation_context.includes, before_each = "-I")
        args.add_all(merged_compilation_context.quote_includes, before_each = "-iquote")
        args.add_all(merged_compilation_context.system_includes, before_each = "-isystem")

        # Add defines from dependencies
        args.add_all(merged_compilation_context.defines, format_each = "-D%s")

        # Add user-provided compiler options
        args.add_all(ctx.attr.copts)

        # Add source and output
        args.add(src)
        args.add("-o", obj)

        ctx.actions.run(
            executable = hipcc_file,
            arguments = [args],
            inputs = depset(
                direct = [src] + ctx.files.hdrs,
                transitive = [
                    merged_compilation_context.headers,
                    cc_toolchain.all_files,
                ],
            ),
            outputs = [obj],
            env = env_vars,
            mnemonic = "RocmCompile",
        )

        objects.append(obj)

    # Create static archive from object files using hermetic llvm-ar
    output_archive = ctx.actions.declare_file("lib" + ctx.label.name + ".pic.a")

    # Use hermetic llvm-ar directly
    llvm_ar_files = ctx.files._llvm_ar
    if len(llvm_ar_files) != 1:
        fail("Expected exactly one llvm-ar file, got: %s" % llvm_ar_files)
    llvm_ar = llvm_ar_files[0]

    # Build archive command
    args = ctx.actions.args()
    args.add("rcsD")
    args.add(output_archive)
    args.add_all(objects)

    ctx.actions.run(
        executable = llvm_ar,
        arguments = [args],
        inputs = depset(direct = objects),
        outputs = [output_archive],
        mnemonic = "RocmArchive",
        progress_message = "Creating archive %s" % output_archive.short_path,
    )

    # Create library_to_link with the archive
    library_to_link = cc_common.create_library_to_link(
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        pic_static_library = output_archive,
        alwayslink = ctx.attr.alwayslink,
    )

    # Create linker_input containing the library
    linker_input = cc_common.create_linker_input(
        owner = ctx.label,
        libraries = depset(direct = [library_to_link]),
    )

    # Create linking_context
    linking_context = cc_common.create_linking_context(
        linker_inputs = depset(direct = [linker_input]),
    )

    # Create CcInfo with linking context
    cc_info = CcInfo(
        linking_context = linking_context,
    )

    return [
        DefaultInfo(files = depset([output_archive])),
        cc_info,
    ]

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
        "alwayslink": attr.bool(
            default = False,
            doc = "If true, link all symbols even if not referenced",
        ),
        "linkstatic": attr.bool(
            default = False,
            doc = "Ignored - object files are always linked into final binary",
        ),
        "_cc_toolchain": attr.label(
            default = "//cc/impls/linux_x86_64_linux_x86_64_rocm:toolchain",
        ),
        "_hipcc": attr.label(
            default = "@config_rocm_hipcc//rocm:hipcc",
            allow_files = True,
        ),
        "_llvm_ar": attr.label(
            default = "@llvm_linux_x86_64//:ar",
            allow_files = True,
        ),
    },
    fragments = ["cpp"],
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"],
)
