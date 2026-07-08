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

"""Macro to create sanitizer wrapper targets with llvm-symbolizer support."""

load("@rules_shell//shell:sh_binary.bzl", "sh_binary")

def sanitizer_wrapper(
        name,
        llvm_symbolizer,
        asan_ignore_list = None,
        lsan_ignore_list = None,
        tsan_ignore_list = None,
        asan_options = None,
        tsan_options = None,
        additional_data = [],
        tags = ["manual"],
        visibility = None):
    """Creates a sanitizer wrapper binary that configures symbolizer and options.

    This macro generates a shell wrapper that:
    1. Locates llvm-symbolizer in runfiles
    2. Sets ASAN_OPTIONS/TSAN_OPTIONS with symbolizer path
    3. Applies ignore lists and custom options
    4. Executes the wrapped test/binary

    Usage with --run_under:
        bazel test --config=asan --run_under=//path/to:sanitizer_wrapper //your:test

    Args:
        name: Name of the sh_binary wrapper target
        llvm_symbolizer: Label to llvm-symbolizer binary (e.g., "@llvm_linux_x86_64//:llvm-symbolizer")
        asan_ignore_list: Optional label to ASAN ignore list file
        lsan_ignore_list: Optional label to LSAN (leak sanitizer) ignore list file
        tsan_ignore_list: Optional label to TSAN ignore list file
        asan_options: Optional string of additional ASAN_OPTIONS (e.g., "detect_leaks=0:malloc_context_size=5")
        tsan_options: Optional string of additional TSAN_OPTIONS (e.g., "halt_on_error=1:exitcode=66")
        additional_data: Additional data dependencies for the wrapper
        tags: Tags for the sh_binary (default: ["manual"])
        visibility: Visibility of the generated target
    """

    # Collect ignore list files
    ignore_lists = []
    if asan_ignore_list:
        ignore_lists.append(asan_ignore_list)
    if lsan_ignore_list:
        ignore_lists.append(lsan_ignore_list)
    if tsan_ignore_list:
        ignore_lists.append(tsan_ignore_list)

    # Generate the wrapper script
    script_name = name + "_script"
    _sanitizer_wrapper_script(
        name = script_name,
        asan_ignore_list = asan_ignore_list,
        lsan_ignore_list = lsan_ignore_list,
        tsan_ignore_list = tsan_ignore_list,
        asan_options = asan_options,
        tsan_options = tsan_options,
        srcs = ignore_lists,
    )

    # Create the sh_binary with all dependencies
    data_deps = [llvm_symbolizer] + ignore_lists + additional_data

    sh_binary(
        name = name,
        srcs = [":" + script_name],
        data = data_deps,
        tags = tags,
        visibility = visibility,
    )

def _sanitizer_wrapper_script_impl(ctx):
    """Implementation for generating the sanitizer wrapper script."""
    output = ctx.outputs.out

    # Build the script content
    script_lines = [
        "#!/bin/bash",
        "# Auto-generated sanitizer wrapper",
        "# Configures symbolizer and sanitizer options for tests",
        "",
        "set -euo pipefail",
        "",
        "# Locate wrapper runfiles directory",
        'wrapper_runfiles="${RUNFILES_DIR:-$0.runfiles}"',
        "",
        "# Find llvm-symbolizer in runfiles",
        "# This searches for any llvm*_linux_*/bin/llvm-symbolizer to support multiple LLVM versions",
        'symbolizer=$(find -L "${wrapper_runfiles}" -path "*/llvm*/bin/llvm-symbolizer" -type f 2>/dev/null | head -n 1)',
        "",
        'if [ -z "${symbolizer}" ]; then',
        '  echo "Warning: llvm-symbolizer not found in runfiles, symbolization may not work" >&2',
        "fi",
        "",
    ]

    # Add ASAN configuration
    asan_opts = []
    if ctx.attr.asan_ignore_list:
        asan_ignore_path = ctx.file.asan_ignore_list.short_path
        asan_opts.append('suppressions="${wrapper_runfiles}/' + asan_ignore_path + '"')
    if ctx.attr.asan_options:
        asan_opts.append(ctx.attr.asan_options)

    if asan_opts or ctx.attr.asan_ignore_list:
        script_lines.extend([
            "# Configure ASAN options",
            'ASAN_BASE_OPTIONS="' + ":".join(asan_opts) + '"',
            'if [ -n "${symbolizer}" ]; then',
            '  ASAN_BASE_OPTIONS="${ASAN_BASE_OPTIONS}:external_symbolizer_path=${symbolizer}"',
            'fi',
            'export ASAN_OPTIONS="${ASAN_OPTIONS:-}${ASAN_OPTIONS:+:}${ASAN_BASE_OPTIONS}"',
            "",
        ])

    # Add LSAN configuration
    lsan_opts = []
    if ctx.attr.lsan_ignore_list:
        lsan_ignore_path = ctx.file.lsan_ignore_list.short_path
        lsan_opts.append('suppressions="${wrapper_runfiles}/' + lsan_ignore_path + '"')

    if lsan_opts:
        script_lines.extend([
            "# Configure LSAN (Leak Sanitizer) options",
            'LSAN_BASE_OPTIONS="' + ":".join(lsan_opts) + '"',
            'export LSAN_OPTIONS="${LSAN_OPTIONS:-}${LSAN_OPTIONS:+:}${LSAN_BASE_OPTIONS}"',
            "",
        ])

    # Add TSAN configuration
    tsan_opts = []
    if ctx.attr.tsan_ignore_list:
        tsan_ignore_path = ctx.file.tsan_ignore_list.short_path
        tsan_opts.append('suppressions="${wrapper_runfiles}/' + tsan_ignore_path + '"')
    if ctx.attr.tsan_options:
        tsan_opts.append(ctx.attr.tsan_options)

    if tsan_opts or ctx.attr.tsan_ignore_list:
        script_lines.extend([
            "# Configure TSAN options",
            'TSAN_BASE_OPTIONS="' + ":".join(tsan_opts) + '"',
            'if [ -n "${symbolizer}" ]; then',
            '  TSAN_BASE_OPTIONS="${TSAN_BASE_OPTIONS}:external_symbolizer_path=${symbolizer}"',
            'fi',
            'export TSAN_OPTIONS="${TSAN_OPTIONS:-}${TSAN_OPTIONS:+:}${TSAN_BASE_OPTIONS}"',
            "",
        ])

    # Execute the wrapped binary
    script_lines.extend([
        "# Execute the wrapped test/binary",
        'exec "$@"',
        "",
    ])

    ctx.actions.write(
        output = output,
        content = "\n".join(script_lines),
        is_executable = True,
    )

    return [DefaultInfo(files = depset([output]))]

_sanitizer_wrapper_script = rule(
    implementation = _sanitizer_wrapper_script_impl,
    attrs = {
        "asan_ignore_list": attr.label(
            allow_single_file = True,
            doc = "ASAN suppressions file",
        ),
        "lsan_ignore_list": attr.label(
            allow_single_file = True,
            doc = "LSAN suppressions file",
        ),
        "tsan_ignore_list": attr.label(
            allow_single_file = True,
            doc = "TSAN suppressions file",
        ),
        "asan_options": attr.string(
            doc = "Additional ASAN_OPTIONS (colon-separated)",
        ),
        "tsan_options": attr.string(
            doc = "Additional TSAN_OPTIONS (colon-separated)",
        ),
        "srcs": attr.label_list(
            allow_files = True,
            doc = "Source files (ignore lists) to trigger rebuild on change",
        ),
    },
    outputs = {
        "out": "%{name}.sh",
    },
)
