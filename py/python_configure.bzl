# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Repository rule for Python autoconfiguration.
"""

load("@python_version_repo//:py_version.bzl", "HERMETIC_PYTHON_VERSION")
load("@pythons_hub//:interpreters.bzl", "INTERPRETER_LABELS")

BAZEL_SH = "BAZEL_SH"
PYTHON_BIN_PATH = "PYTHON_BIN_PATH"
PYTHON_LIB_PATH = "PYTHON_LIB_PATH"

def _is_bzlmod_enabled():
    return str(Label("@//:BUILD.bazel")).startswith("@@")

def _get_python_interpreter():
    python_toolchain_name = "python_{version}_host".format(
        version = HERMETIC_PYTHON_VERSION.replace(".", "_"),
    )
    if _is_bzlmod_enabled():
        return str(INTERPRETER_LABELS[python_toolchain_name])
    return "@{}//:python".format(python_toolchain_name)

def _create_local_python_repository(repository_ctx):
    """Creates the repository containing files set up to build with Python."""

    platform_constraint = ""
    if repository_ctx.attr.platform_constraint:
        platform_constraint = "\"%s\"" % repository_ctx.attr.platform_constraint
    repository_ctx.template(
        "BUILD",
        repository_ctx.attr.build_tpl,
        {
            "%{PLATFORM_CONSTRAINT}": platform_constraint,
            "%{PYTHON_INTERPRETER}": repository_ctx.attr.python_interpreter,
        },
    )

def _python_autoconf_impl(repository_ctx):
    """Implementation of the python_autoconf repository rule."""
    _create_local_python_repository(repository_ctx)

_ENVIRONS = [
    BAZEL_SH,
    PYTHON_BIN_PATH,
    PYTHON_LIB_PATH,
]

local_python_configure = repository_rule(
    implementation = _create_local_python_repository,
    attrs = {
        "environ": attr.string_dict(),
        "platform_constraint": attr.string(),
        "build_tpl": attr.label(default = Label("//py:BUILD.tpl")),
        "python_interpreter": attr.string(default = _get_python_interpreter()),
    },
)

remote_python_configure = repository_rule(
    implementation = _create_local_python_repository,
    environ = _ENVIRONS,
    #remotable = True,
    attrs = {
        "environ": attr.string_dict(),
        "platform_constraint": attr.string(),
        "build_tpl": attr.label(default = Label("//py:BUILD.tpl")),
        "python_interpreter": attr.string(default = _get_python_interpreter()),
    },
)

python_configure = repository_rule(
    implementation = _python_autoconf_impl,
    attrs = {
        "platform_constraint": attr.string(),
        "build_tpl": attr.label(default = Label("//py:BUILD.tpl")),
        "python_interpreter": attr.string(default = _get_python_interpreter()),
    },
)
"""Detects and configures the local Python.

Add the following to your WORKSPACE FILE:

```python
python_configure(name = "local_config_python")
```

Args:
  name: A unique name for this workspace rule.
"""
