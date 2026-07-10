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

def sanitizer_wrapper(
        name,
        llvm_symbolizer,
        asan_options,
        tsan_options,
        asan_ignore_list = None,
        lsan_ignore_list = None,
        tsan_ignore_list = None,
        run_under = None,
        additional_data = [],
        tags = ["manual"],
        visibility = None):
    """Creates a sanitizer wrapper binary that configures symbolizer and options.

    Args:
        name: Name of the sh_binary wrapper target
        llvm_symbolizer: Label to llvm-symbolizer binary
        asan_options: ASAN_OPTIONS string
        tsan_options: TSAN_OPTIONS string
        asan_ignore_list: Optional ASAN ignore list file
        lsan_ignore_list: Optional LSAN ignore list file
        tsan_ignore_list: Optional TSAN ignore list file
        run_under: Optional script to run under (e.g., parallel_gpu_execute)
        additional_data: Additional data dependencies
        tags: Tags for the sh_binary
        visibility: Visibility of the target
    """

    # Generate wrapper script
    script_name = name + "_script"
    _sanitizer_wrapper_script(
        name = script_name,
        asan_options = asan_options,
        tsan_options = tsan_options,
        asan_ignore_list = asan_ignore_list,
        lsan_ignore_list = lsan_ignore_list,
        tsan_ignore_list = tsan_ignore_list,
        run_under = run_under,
    )

    ignore_lists = []
    if asan_ignore_list:
        ignore_lists.append(asan_ignore_list)
    if lsan_ignore_list:
        ignore_lists.append(lsan_ignore_list)
    if tsan_ignore_list:
        ignore_lists.append(tsan_ignore_list)

    data_deps = [llvm_symbolizer] + ignore_lists + additional_data
    if run_under:
        data_deps.append(run_under)

    native.sh_binary(
        name = name,
        srcs = [":" + script_name],
        data = data_deps,
        tags = tags,
        visibility = visibility,
    )

def _sanitizer_wrapper_script_impl(ctx):
    """Generate sanitizer wrapper script from template."""
    # Helper to get runfiles path for a file
    def get_runfiles_path(file):
        # For external repos, short_path starts with ../repo_name/
        # For main workspace, short_path is relative to workspace root
        if file.short_path.startswith("../"):
            # External repo: ../repo_name/path -> repo_name/path
            return file.short_path[3:]
        else:
            # Main workspace: prepend workspace name
            workspace_name = ctx.label.workspace_name if ctx.label.workspace_name else ctx.workspace_name
            return workspace_name + "/" + file.short_path

    # Build options with proper runfiles paths
    asan_opts = [ctx.attr.asan_options]
    if ctx.attr.asan_ignore_list:
        asan_opts.append('suppressions="${wrapper_runfiles}/' + get_runfiles_path(ctx.file.asan_ignore_list) + '"')

    lsan_opts = []
    if ctx.attr.lsan_ignore_list:
        lsan_opts.append('suppressions="${wrapper_runfiles}/' + get_runfiles_path(ctx.file.lsan_ignore_list) + '"')

    tsan_opts = [ctx.attr.tsan_options]
    if ctx.attr.tsan_ignore_list:
        tsan_opts.append('suppressions="${wrapper_runfiles}/' + get_runfiles_path(ctx.file.tsan_ignore_list) + '"')

    # Build exec command
    if ctx.attr.run_under:
        # For executables, use the executable's runfiles path
        # sh_binary and other executables have their path in ctx.executable
        executable_path = ctx.executable.run_under.short_path
        if executable_path.startswith("../"):
            # External repo
            runfiles_path = executable_path[3:]
        else:
            # Main workspace
            workspace_name = ctx.label.workspace_name if ctx.label.workspace_name else ctx.workspace_name
            runfiles_path = workspace_name + "/" + executable_path
        exec_cmd = 'exec "${wrapper_runfiles}/%s" "$@"' % runfiles_path
    else:
        exec_cmd = 'exec "$@"'

    ctx.actions.expand_template(
        template = ctx.file.template,
        output = ctx.outputs.out,
        substitutions = {
            "{ASAN_BASE_OPTIONS}": ":".join(asan_opts),
            "{LSAN_BASE_OPTIONS}": ":".join(lsan_opts),
            "{TSAN_BASE_OPTIONS}": ":".join(tsan_opts),
            "{RUN_UNDER_EXEC}": exec_cmd,
        },
        is_executable = True,
    )

    return [DefaultInfo(files = depset([ctx.outputs.out]))]

_sanitizer_wrapper_script = rule(
    implementation = _sanitizer_wrapper_script_impl,
    attrs = {
        "asan_options": attr.string(),
        "tsan_options": attr.string(),
        "asan_ignore_list": attr.label(allow_single_file = True),
        "lsan_ignore_list": attr.label(allow_single_file = True),
        "tsan_ignore_list": attr.label(allow_single_file = True),
        "run_under": attr.label(executable = True, cfg = "target"),
        "template": attr.label(
            default = Label("//cc/sanitizers:sanitizer_wrapper.sh.tpl"),
            allow_single_file = True,
        ),
    },
    outputs = {"out": "%{name}.sh"},
)
