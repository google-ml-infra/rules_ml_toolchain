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

"""Repository rule for creating a local system sysroot.

This rule creates a repository that uses the local system's sysroot,
useful for non-hermetic builds or when you want to use the system's
C/C++ standard library.

Example usage in MODULE.bazel or WORKSPACE:
    local_sysroot(
        name = "local_sysroot_linux_x86_64",
        sysroot_path = "/",  # or specific path
    )
"""

def _local_sysroot_impl(repository_ctx):
    """Implementation of the local_sysroot repository rule."""

    # Get sysroot path from attribute or environment variable
    sysroot_path = repository_ctx.attr.sysroot_path
    if not sysroot_path:
        sysroot_path = repository_ctx.os.environ.get("SYSROOT_PATH", "/")

    # On Linux, symlink to the system root
    repository_ctx.symlink(sysroot_path, "sysroot")

    # Create BUILD file matching the hermetic sysroot interface
    repository_ctx.file("BUILD", """
filegroup(
    name = "sysroot",
    srcs = [],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "includes_c",
    srcs = glob([
        "sysroot/usr/include/**/*.h",
    ], allow_empty = True),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "includes_system",
    srcs = glob([
        "sysroot/usr/include/c++/**",
        "sysroot/usr/include/x86_64-linux-gnu/c++/**",
        "sysroot/usr/include/aarch64-linux-gnu/c++/**",
    ], allow_empty = True),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "syslibs",
    srcs = glob([
        "sysroot/usr/lib/**/*.so*",
        "sysroot/usr/lib/**/*.a",
        "sysroot/lib/**/*.so*",
        "sysroot/lib/**/*.a",
    ], allow_empty = True),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "startup_libs",
    srcs = glob([
        "sysroot/usr/lib/x86_64-linux-gnu/crt*.o",
        "sysroot/usr/lib/aarch64-linux-gnu/crt*.o",
    ], allow_empty = True),
    visibility = ["//visibility:public"],
)
""")

local_sysroot = repository_rule(
    implementation = _local_sysroot_impl,
    attrs = {
        "sysroot_path": attr.string(
            doc = "Path to the system sysroot. Defaults to '/' if not specified.",
            default = "",
        ),
    },
    environ = ["SYSROOT_PATH"],
    doc = """Creates a repository using the local system's sysroot.

    This is useful for non-hermetic builds where you want to use the system's
    C/C++ standard library instead of a hermetic sysroot.

    Args:
        sysroot_path: Path to the sysroot directory. If not specified, uses
                     the SYSROOT_PATH environment variable or defaults to '/'.
    """,
)
