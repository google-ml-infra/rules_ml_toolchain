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

"""Rule for patching libc++abi.a with futex-based cxa_guard (InitByteFutex)."""

def _libcxxabi_futex_impl(ctx):
    cxa_guard_obj = ctx.actions.declare_file(ctx.label.name + "/cxa_guard.cpp.o")
    out_archive = ctx.actions.declare_file(ctx.label.name + "/libc++abi.a")

    ctx.actions.run(
        executable = ctx.file._compiler,
        arguments = [
            "-c",
            ctx.file._src.path,
            "-o",
            cxa_guard_obj.path,
            "--target=" + ctx.attr.target,
            "-O2",
            "-fPIC",
            "-fvisibility=hidden",
            "-funwind-tables",
            "-std=c++20",
            "-nostdinc",
            "-nostdinc++",
            "-fno-exceptions",
            "-fno-rtti",
        ],
        inputs = [ctx.file._src] + ctx.files._distro_libs,
        outputs = [cxa_guard_obj],
        mnemonic = "CompileLibcxxabiCxaGuardFutex",
    )

    ctx.actions.run_shell(
        inputs = [ctx.file.src_archive, cxa_guard_obj] + ctx.files._distro_libs,
        outputs = [out_archive],
        tools = [ctx.file._archiver],
        command = 'cp -f "$1" "$2" && chmod +w "$2" && "$3" rcsD "$2" "$4"',
        arguments = [
            ctx.file.src_archive.path,
            out_archive.path,
            ctx.file._archiver.path,
            cxa_guard_obj.path,
        ],
        mnemonic = "ArchiveLibcxxabiFutex",
    )

    return [
        DefaultInfo(files = depset([out_archive])),
    ]

libcxxabi_futex = rule(
    implementation = _libcxxabi_futex_impl,
    attrs = {
        "src_archive": attr.label(
            allow_single_file = [".a"],
            mandatory = True,
            doc = "The prebuilt libc++abi.a archive whose cxa_guard.cpp.o member will be replaced.",
        ),
        "target": attr.string(
            mandatory = True,
            doc = "Target triple (e.g., x86_64-unknown-linux-gnu or aarch64-unknown-linux-gnu).",
        ),
        "_src": attr.label(
            default = Label("//cc/libcxxabi:cxa_guard_futex.cc"),
            allow_single_file = True,
        ),
        "_compiler": attr.label(
            default = Label("//cc/libcxxabi:exec_clang++"),
            allow_single_file = True,
            cfg = "exec",
        ),
        "_archiver": attr.label(
            default = Label("//cc/libcxxabi:exec_ar"),
            allow_single_file = True,
            cfg = "exec",
        ),
        "_distro_libs": attr.label(
            default = Label("//cc/libcxxabi:exec_distro_libs"),
            allow_files = True,
            cfg = "exec",
        ),
    },
    doc = "Replaces cxa_guard.cpp.o in libc++abi.a with the InitByteFutex implementation.",
)
