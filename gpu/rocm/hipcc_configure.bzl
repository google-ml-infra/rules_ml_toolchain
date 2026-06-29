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

"""Repository rule for hermetic ROCm autoconfiguration.

`hipcc_configure` depends on the following:

  * `rocm_dist` attribute: Label pointing to hermetic ROCm distribution from rocm_hermetic_download.
  * `TF_ROCM_AMDGPU_TARGETS`: The AMDGPU targets (optional, defaults based on ROCm version).
"""

load("@bazel_skylib//lib:paths.bzl", "paths")
load(
    "//common:common.bzl",
    "err_out",
    "execute",
    "files_exist",
    "get_bash_bin",
    "get_python_bin",
)
# No longer need download logic - consumers handle downloads

def _enable_rocm(repository_ctx):
    """Returns whether to build with ROCm support."""

    # Check TF_NEED_ROCM environment variable
    # rocm_dist is always provided (mandatory), but we only use it if TF_NEED_ROCM=1
    enable_rocm = repository_ctx.os.environ.get("TF_NEED_ROCM")
    if enable_rocm == "1":
        return True
    return False

_TF_ROCM_AMDGPU_TARGETS = "TF_ROCM_AMDGPU_TARGETS"
_TF_ROCM_CONFIG_REPO = "TF_ROCM_CONFIG_REPO"

# Removed: _TF_ROCM_MULTIPLE_PATHS and _LLVM_PATH - only hermetic builds supported
_DISTRIBUTION_PATH = "rocm/rocm_dist"

def auto_configure_fail(msg):
    """Output failure message when rocm configuration fails."""
    red = "\033[0;31m"
    no_color = "\033[0m"
    fail("\n%sROCm Configuration Error:%s %s\n" % (red, no_color, msg))

def auto_configure_warning(msg):
    """Output warning message during auto configuration."""
    yellow = "\033[1;33m"
    no_color = "\033[0m"
    print("\n%sAuto-Configuration Warning:%s %s\n" % (yellow, no_color, msg))

def _amdgpu_targets(repository_ctx, rocm_toolkit_path, bash_bin):
    """Returns a list of strings representing AMDGPU targets."""
    amdgpu_targets_str = repository_ctx.os.environ.get(_TF_ROCM_AMDGPU_TARGETS)
    if not amdgpu_targets_str:
        cmd = "%s/bin/rocm_agent_enumerator" % rocm_toolkit_path
        result = execute(repository_ctx, [bash_bin, "-c", cmd])
        targets = [target for target in result.stdout.strip().split("\n") if target != "gfx000"]
        targets = {x: None for x in targets}
        targets = list(targets.keys())
        amdgpu_targets_str = ",".join(targets)
    amdgpu_targets = [amdgpu for amdgpu in amdgpu_targets_str.split(",") if amdgpu]
    for amdgpu_target in amdgpu_targets:
        if amdgpu_target[:3] != "gfx":
            auto_configure_fail("Invalid AMDGPU target: %s" % amdgpu_target)
    return amdgpu_targets

def find_rocm_config(repository_ctx):
    """Returns ROCm config dictionary from running find_rocm_config.py"""
    python_bin = get_python_bin(repository_ctx)
    exec_result = execute(repository_ctx, [python_bin, repository_ctx.attr._find_rocm_config], env_vars = {"ROCM_PATH": _DISTRIBUTION_PATH})
    if exec_result.return_code:
        auto_configure_fail("Failed to run find_rocm_config.py: %s" % err_out(exec_result))

    # Parse the dict from stdout.
    return dict([tuple(x.split(": ")) for x in exec_result.stdout.splitlines()])

def _get_rocm_config(repository_ctx, bash_bin, install_path):
    """Detects and returns information about the ROCm installation on the system.

    Args:
      repository_ctx: The repository context.
      bash_bin: the path to the path interpreter
      rocm_path: Path to ROCm installation.
      install_path: Original install path (for non-hermetic builds).

    Returns:
      A struct containing the following fields:
        rocm_toolkit_path: The ROCm toolkit installation directory.
        amdgpu_targets: A list of the system's AMDGPU targets.
        rocm_version_number: The version of ROCm on the system.
        hipruntime_version_number: The version of HIP Runtime on the system.
        clang_version: The clang version in ROCm's LLVM.
        install_path: Original install path.
        rocm_lib_paths: List of lib paths (for multiple paths setup).
    """
    config = find_rocm_config(repository_ctx)
    rocm_toolkit_path = config["rocm_toolkit_path"]
    rocm_version_number = config["rocm_version_number"]
    hipruntime_version_number = config["hipruntime_version_number"]
    clang_version = config.get("clang_version", "")
    return struct(
        amdgpu_targets = _amdgpu_targets(repository_ctx, rocm_toolkit_path, bash_bin),
        rocm_toolkit_path = rocm_toolkit_path,
        rocm_version_number = rocm_version_number,
        hipruntime_version_number = hipruntime_version_number,
        clang_version = clang_version,
        install_path = install_path,
    )

def _tpl_path(repository_ctx, labelname):
    """Convert a template label name to a path within rules_ml_toolchain.

    labelname formats:
      - "rocm:BUILD" -> //gpu/rocm:BUILD.tpl
    """
    if labelname.startswith("rocm:"):
        # rocm:xxx -> //gpu/rocm:xxx.tpl
        return repository_ctx.path(Label("//gpu/rocm:%s.tpl" % labelname[5:]))
    else:
        return repository_ctx.path(Label("//gpu/rocm:%s.tpl" % labelname))

def _tpl(repository_ctx, tpl, substitutions = {}, out = None):
    if not out:
        out = tpl.replace(":", "/")
    repository_ctx.template(
        out,
        _tpl_path(repository_ctx, tpl),
        substitutions,
    )

def _norm_path(path):
    """Returns a path with '/' and remove the trailing slash."""
    path = path.replace("\\", "/")
    if path[-1] == "/":
        path = path[:-1]
    return path

def _canonical_path(p):
    parts = [x for x in p.split("/") if x != ""]
    return paths.join(*parts)

def _remove_root_dir(path, root_dir):
    if path.startswith(root_dir + "/"):
        return path[len(root_dir) + 1:]
    return path

# Removed: _setup_rocm_from_multiple_paths - only hermetic builds supported

def _setup_rocm_distro_dir(repository_ctx):
    """Sets up the rocm hermetic installation directory from rocm_dist label"""
    bash_bin = get_bash_bin(repository_ctx)

    # rocm_dist attribute is mandatory
    rocm_dist_label = repository_ctx.attr.rocm_dist

    # Get the path to the rocm_dist directory from the label
    # The label points to a filegroup target (e.g., @rocm_hermetic_dist//:rocm_root)
    # We need to get the directory where the BUILD file is, then find rocm_dist subdirectory
    rocm_dist_target_path = repository_ctx.path(rocm_dist_label)

    # The target is in a BUILD file, so get its directory
    # Then look for rocm_dist subdirectory (this is where the actual distribution is)
    package_dir = rocm_dist_target_path.dirname
    rocm_dist_path = package_dir.get_child("rocm_dist")

    # Extract repository name for logging (use workspace_name from the label)
    rocm_source_repo = str(rocm_dist_label).split("//")[0].lstrip("@")
    auto_configure_warning("Using hermetic ROCm from: {}".format(rocm_source_repo))

    repository_ctx.symlink(rocm_dist_path, _DISTRIBUTION_PATH)

    rocm_config_with_source = _get_rocm_config(repository_ctx, bash_bin, "")

    # Add source repo to config as a custom field - merge the struct fields
    # Filter out built-in methods (to_json, to_proto)
    config_dict = {k: getattr(rocm_config_with_source, k) for k in dir(rocm_config_with_source) if not k.startswith("to_")}
    config_dict["rocm_source_repo"] = rocm_source_repo
    return struct(**config_dict)

def _create_dummy_repository(repository_ctx):
    """Creates a stub ROCm repository when ROCm is not enabled."""

    # Create stub repository using templates with empty values
    repository_ctx.file("rocm/empty/.keep", "")
    stub_dict = {
        "%{rocm_root}": "empty",
        "%{rocm_gpu_architectures}": "[]",
        "%{rocm_version_number}": "0",
        "%{hipruntime_version_number}": "0",
        "%{hipcc_path}": "",
        "%{clang_version}": "",
    }

    _tpl(repository_ctx, "rocm:BUILD", stub_dict)
    _tpl(repository_ctx, "rocm:build_defs.bzl", stub_dict)

def _setup_rocm_repository(repository_ctx):
    """Sets up the ROCm repository when ROCm is enabled."""
    rocm_config = _setup_rocm_distro_dir(repository_ctx)
    rocm_version_number = int(rocm_config.rocm_version_number)
    hipruntime_version_number = int(rocm_config.hipruntime_version_number)

    # Handle hermetic vs non-hermetic ROCm
    if rocm_config.install_path:
        # Non-hermetic: symlink already created in _setup_rocm_distro_dir
        # Use "rocm_dist" (relative to rocm/ directory where BUILD file is)
        rocm_toolkit_path = "rocm_dist"
    else:
        # Hermetic: files already extracted to rocm/rocm_dist
        rocm_toolkit_path = _remove_root_dir(rocm_config.rocm_toolkit_path, "rocm")

    # Always use relative paths (either symlink or hermetic dist)
    rocm_path_relative = "rocm_dist"
    hipcc_path_relative = rocm_path_relative + "/bin/hipcc"

    bash_bin = get_bash_bin(repository_ctx)

    clang_offload_bundler_path = rocm_toolkit_path + "/llvm/bin/clang-offload-bundler"

    # Get source repository (always set since we only support hermetic builds)
    rocm_source_repo = rocm_config.rocm_source_repo

    repository_dict = {
        "%{rocm_root}": rocm_toolkit_path,
        "%{rocm_source_repo}": rocm_source_repo,
        "%{rocm_gpu_architectures}": str(rocm_config.amdgpu_targets),
        "%{rocm_version_number}": str(rocm_version_number),
        "%{hipruntime_version_number}": str(hipruntime_version_number),
        "%{hipcc_path}": hipcc_path_relative,
        "%{clang_version}": rocm_config.clang_version,
    }

    _tpl(repository_ctx, "rocm:BUILD", repository_dict)
    _tpl(repository_ctx, "rocm:build_defs.bzl", repository_dict)

def _hipcc_autoconf_impl(repository_ctx):
    """Implementation of the hipcc_configure repository rule."""
    if not _enable_rocm(repository_ctx):
        _create_dummy_repository(repository_ctx)
    else:
        _setup_rocm_repository(repository_ctx)

hipcc_configure = repository_rule(
    implementation = _hipcc_autoconf_impl,
    environ = [
        "TF_NEED_ROCM",
        "TF_ROCM_AMDGPU_TARGETS",
    ],
    attrs = {
        "rocm_dist": attr.label(
            mandatory = True,
            doc = "Label to the ROCm distribution " +
                  "(e.g. @rocm_hermetic_dist//:rocm_root or @local_config_rocm//:rocm_root).",
        ),
        "_find_rocm_config": attr.label(
            default = Label("//gpu/rocm:find_rocm_config.py"),
        ),
    },
)
"""Detects and configures the local ROCm toolchain.

Add the following to your WORKSPACE FILE:

```python
hipcc_configure(name = "config_rocm_hipcc")
```

Args:
  name: A unique name for this workspace rule.hipcc_config
"""
