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
        asan_options,
        tsan_options,
        asan_ignore_list = None,
        lsan_ignore_list = None,
        tsan_ignore_list = None,
        run_under = None,
        extra_sanitizer_rt = [],
        data = [],
        additional_data = [],
        tags = ["manual"],
        visibility = None):
    """Creates a sanitizer wrapper binary that configures symbolizer and options.

    Args:
        name: Name of the sh_binary wrapper target
        llvm_symbolizer: Label to llvm-symbolizer binary. The sanitizer
            runtime shared library (e.g. libclang_rt.asan.so) needed by
            dynamic sanitizer builds is derived automatically from the same
            package as this label, via its ":rt_asan"/":rt_tsan" sibling
            targets -- every toolchain distro repo in this project exposes
            those cc_toolchain_import targets next to its llvm-symbolizer
            binary, already correctly populated for that version.
        asan_options: ASAN_OPTIONS string
        tsan_options: TSAN_OPTIONS string
        asan_ignore_list: Optional ASAN ignore list file
        lsan_ignore_list: Optional LSAN ignore list file
        tsan_ignore_list: Optional TSAN ignore list file
        run_under: Optional script to run under (e.g., parallel_gpu_execute)
        extra_sanitizer_rt: Optional sanitizer runtime targets to prefer over
            the automatically derived default (e.g. a vendor-specific
            prebuilt library that needs a matching, differently-versioned
            runtime). Checked in list order, ahead of the default.
        data: Additional data dependencies unrelated to the sanitizer
            runtime (e.g. a `rocminfo` binary needed by run_under).
        additional_data: Deprecated alias for `data`, kept for backward
            compatibility with existing callers (e.g., XLA).
        tags: Tags for the sh_binary
        visibility: Visibility of the target
    """

    # Every toolchain distro repo in this project exposes ":rt_asan"/":rt_tsan"
    # cc_toolchain_import targets (the same ones the "asan"/"tsan" toolchain
    # features link against) in the same package as its llvm-symbolizer
    # binary, already correctly populated with that version's dynamic
    # sanitizer runtimes -- derive them automatically instead of asking every
    # caller to wire up a runtime location by hand.
    symbolizer_label = Label(llvm_symbolizer)
    sanitizer_rt = list(extra_sanitizer_rt) + [
        symbolizer_label.same_package_label("rt_asan"),
        symbolizer_label.same_package_label("rt_tsan"),
    ]

    # Generate wrapper script (always tag as manual so wildcard builds like
    # //build_tools/... do not build the internal helper and pull Linux LLVM
    # sanitizer runtimes on non-Linux hosts).
    script_name = name + "_script"
    script_tags = list(tags) if tags else []
    if "manual" not in script_tags:
        script_tags.append("manual")
    _sanitizer_wrapper_script(
        name = script_name,
        asan_options = asan_options,
        tsan_options = tsan_options,
        asan_ignore_list = asan_ignore_list,
        lsan_ignore_list = lsan_ignore_list,
        tsan_ignore_list = tsan_ignore_list,
        run_under = run_under,
        sanitizer_rt = sanitizer_rt,
        tags = script_tags,
    )

    ignore_lists = []
    if asan_ignore_list:
        ignore_lists.append(asan_ignore_list)
    if lsan_ignore_list:
        ignore_lists.append(lsan_ignore_list)
    if tsan_ignore_list:
        ignore_lists.append(tsan_ignore_list)

    data_deps = [llvm_symbolizer] + ignore_lists + sanitizer_rt
    if run_under:
        data_deps.append(run_under)
    if data:
        data_deps = data_deps + data
    if additional_data:
        data_deps = data_deps + additional_data

    sh_binary(
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

    # Dynamic sanitizer builds need libclang_rt.{asan,tsan,...}.so on the
    # loader path. Resolve it here (analysis time) rather than searching
    # runfiles at run time, so the result is deterministic: the first
    # sanitizer_rt target (in BUILD-declared order) that carries a matching
    # runtime wins. This lets callers put a vendor-specific sanitizer runtime
    # (e.g. one matching an ASan-instrumented SDK build) ahead of the
    # automatically derived toolchain default.
    sanitizer_lib_dir = ""
    for f in ctx.files.sanitizer_rt:
        if f.basename.startswith("libclang_rt.") and f.basename.endswith(".so") and "-" not in f.basename:
            sanitizer_lib_dir = "/".join(get_runfiles_path(f).split("/")[:-1])
            break

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
            "{SANITIZER_LIB_DIR}": sanitizer_lib_dir,
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
        "sanitizer_rt": attr.label_list(allow_files = True),
        "template": attr.label(
            default = Label("//cc/sanitizers:sanitizer_wrapper.sh.tpl"),
            allow_single_file = True,
        ),
    },
    outputs = {"out": "%{name}.sh"},
)
