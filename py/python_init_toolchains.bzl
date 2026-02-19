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

"""Hermetic Python initialization. Consult the WORKSPACE on how to use it."""

load(
    "@python_version_repo//:py_version.bzl",
    "HERMETIC_PYTHON_PREFIX",
    "HERMETIC_PYTHON_SHA256",
    "HERMETIC_PYTHON_URL",
    "HERMETIC_PYTHON_VERSION",
    "HERMETIC_PYTHON_VERSION_KIND",
)
load("@rules_python//python:repositories.bzl", "python_register_toolchains")
load("@rules_python//python:versions.bzl", "MINOR_MAPPING", "PLATFORMS")

def get_toolchain_name_per_python_version(name):
    return "{name}_{version}".format(
        name = name,
        version = HERMETIC_PYTHON_VERSION.replace(".", "_"),
    )

def python_init_toolchains(name = "python", python_version = None, **kwargs):
    """Register hermetic python toolchains.

    Args:
        name: prefix of the toolchain, "python" by default (it is strongly
          recommended to rely on the default).
        python_version: version of the python to register; if set it will bypass
          kwargs to underlying python_register_toolchains as is (manual
          configuration), otherwise it will automatically configure toolchains
          based on HERMETIC_PYTHON_URL and/or based on HERMETIC_PYTHON_VERSION
          repo_env values.
        **kwargs: additional arguments to pass to python_register_toolchains.
    """

    if python_version:
        python_register_toolchains(
            name = get_toolchain_name_per_python_version(name),
            python_version = python_version,
            **kwargs
        )
    elif HERMETIC_PYTHON_URL:
        tool_version = MINOR_MAPPING.get(HERMETIC_PYTHON_VERSION)
        if not tool_version:
            tool_version = HERMETIC_PYTHON_VERSION + ".0"

        sha256s = {}
        for platform in PLATFORMS.keys():
            # Avoid obscure platforms for now just in case
            if "aarch64" in platform or "x86_64" in platform:
                sha256s[platform] = HERMETIC_PYTHON_SHA256

        print("===========================")
        print("name = ", get_toolchain_name_per_python_version(name))
        print("tool_version = ", tool_version)
        print("HERMETIC_PYTHON_URL = ", HERMETIC_PYTHON_URL)
        print("HERMETIC_PYTHON_PREFIX = ", HERMETIC_PYTHON_PREFIX)
        print("===========================")

        python_register_toolchains(
            name = get_toolchain_name_per_python_version(name),
            base_url = "",
            ignore_root_user_error = True,
            python_version = tool_version,
            tool_versions = {
                tool_version: {
                    "url": HERMETIC_PYTHON_URL,
                    "sha256": sha256s,
                    "strip_prefix": HERMETIC_PYTHON_PREFIX,
                },
            },
            # minor_mapping = {HERMETIC_PYTHON_VERSION: tool_version}
        )
    elif HERMETIC_PYTHON_VERSION in MINOR_MAPPING:
        python_register_toolchains(
            name = get_toolchain_name_per_python_version(name),
            ignore_root_user_error = True,
            python_version = HERMETIC_PYTHON_VERSION,
            python_version_kind = HERMETIC_PYTHON_VERSION_KIND,
        )
