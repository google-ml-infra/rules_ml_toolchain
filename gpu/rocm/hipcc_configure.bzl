"""Repository rule for ROCm autoconfiguration.

`rocm_configure` depends on the following environment variables:

  * `ROCM_PATH`: The path to the ROCm toolkit. Default is `/opt/rocm`.
  * `TF_ROCM_AMDGPU_TARGETS`: The AMDGPU targets.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")
load(
    "//common:common.bzl",
    "err_out",
    "execute",
    "files_exist",
    "get_bash_bin",
    "get_host_environ",
    "get_python_bin",
)
load(
    "//gpu/rocm:rocm_redist.bzl",
    "create_rocm_distro",
    "rocm_redist",
)

def enable_sycl(repository_ctx):
    """Returns whether to build with SYCL support."""
    return bool(get_host_environ(repository_ctx, "TF_NEED_SYCL", "").strip())

_TF_ROCM_AMDGPU_TARGETS = "TF_ROCM_AMDGPU_TARGETS"
_TF_ROCM_CONFIG_REPO = "TF_ROCM_CONFIG_REPO"
_DISTRIBUTION_PATH = "rocm/rocm_dist"
_ROCM_DISTRO_VERSION = "ROCM_DISTRO_VERSION"
_ROCM_DISTRO_URL = "ROCM_DISTRO_URL"
_ROCM_DISTRO_HASH = "ROCM_DISTRO_HASH"
_ROCM_DISTRO_LINKS = "ROCM_DISTRO_LINKS"
_TMPDIR = "TMPDIR"

# Default hermetic ROCm redistributable version (gfx90X = MI100, gfx908)
_DEFAULT_ROCM_DISTRO_VERSION = "rocm_7.10.0_gfx90X"

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
    amdgpu_targets_str = get_host_environ(repository_ctx, _TF_ROCM_AMDGPU_TARGETS)
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

def find_rocm_config(repository_ctx, rocm_path):
    """Returns ROCm config dictionary from running find_rocm_config.py"""
    python_bin = get_python_bin(repository_ctx)
    exec_result = execute(repository_ctx, [python_bin, repository_ctx.attr._find_rocm_config], env_vars = {"ROCM_PATH": rocm_path})
    if exec_result.return_code:
        auto_configure_fail("Failed to run find_rocm_config.py: %s" % err_out(exec_result))

    # Parse the dict from stdout.
    return dict([tuple(x.split(": ")) for x in exec_result.stdout.splitlines()])

def _get_rocm_config(repository_ctx, bash_bin, rocm_path, install_path):
    """Detects and returns information about the ROCm installation on the system.

    Args:
      repository_ctx: The repository context.
      bash_bin: the path to the path interpreter

    Returns:
      A struct containing the following fields:
        rocm_toolkit_path: The ROCm toolkit installation directory.
        amdgpu_targets: A list of the system's AMDGPU targets.
        rocm_version_number: The version of ROCm on the system.
        miopen_version_number: The version of MIOpen on the system.
        hipruntime_version_number: The version of HIP Runtime on the system.
    """
    config = find_rocm_config(repository_ctx, rocm_path)
    rocm_toolkit_path = config["rocm_toolkit_path"]
    rocm_version_number = config["rocm_version_number"]
    miopen_version_number = config["miopen_version_number"]
    hipruntime_version_number = config["hipruntime_version_number"]
    return struct(
        amdgpu_targets = _amdgpu_targets(repository_ctx, rocm_toolkit_path, bash_bin),
        rocm_toolkit_path = rocm_toolkit_path,
        rocm_version_number = rocm_version_number,
        miopen_version_number = miopen_version_number,
        hipruntime_version_number = hipruntime_version_number,
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

def _get_file_name(url):
    last_slash_index = url.rfind("/")
    return url[last_slash_index + 1:]

def _download_package(repository_ctx, pkg):
    file_name = _get_file_name(pkg["url"])

    print("Downloading {}".format(pkg["url"]))
    repository_ctx.report_progress("Downloading and extracting {}, expected hash is {}".format(pkg["url"], pkg["sha256"]))  # buildifier: disable=print
    repository_ctx.download_and_extract(
        url = pkg["url"],
        output = _DISTRIBUTION_PATH,
        sha256 = pkg["sha256"],
        type = "zip" if pkg["url"].endswith(".whl") else "",
    )

    if pkg.get("sub_package", None):
        repository_ctx.report_progress("Extracting {}".format(pkg["sub_package"]))  # buildifier: disable=print
        repository_ctx.extract(
            archive = "{}/{}".format(_DISTRIBUTION_PATH, pkg["sub_package"]),
            output = _DISTRIBUTION_PATH,
        )

    repository_ctx.delete(file_name)

def _remove_root_dir(path, root_dir):
    if path.startswith(root_dir + "/"):
        return path[len(root_dir) + 1:]
    return path

def _setup_rocm_distro_dir_impl(repository_ctx, rocm_distro):
    repository_ctx.file("rocm/.index")
    for pkg in rocm_distro.packages:
        _download_package(repository_ctx, pkg)

    for entry in rocm_distro.required_softlinks:
        repository_ctx.symlink(
            "{}/{}".format(_DISTRIBUTION_PATH, entry.target),
            "{}/{}".format(_DISTRIBUTION_PATH, entry.link),
        )
    bash_bin = get_bash_bin(repository_ctx)
    return _get_rocm_config(repository_ctx, bash_bin, _canonical_path("{}/{}".format(_DISTRIBUTION_PATH, rocm_distro.rocm_root)), "")

def _setup_rocm_distro_dir(repository_ctx):
    """Sets up the rocm hermetic installation directory to be used in hermetic build"""
    bash_bin = get_bash_bin(repository_ctx)

    # Check for custom URL-based distro
    rocm_distro_url = repository_ctx.os.environ.get(_ROCM_DISTRO_URL)
    if rocm_distro_url:
        rocm_distro_hash = repository_ctx.os.environ.get(_ROCM_DISTRO_HASH)
        if not rocm_distro_hash:
            fail("{} environment variable is required".format(_ROCM_DISTRO_HASH))
        rocm_distro_links = repository_ctx.os.environ.get(_ROCM_DISTRO_LINKS, "")
        rocm_distro = create_rocm_distro(rocm_distro_url, rocm_distro_hash, rocm_distro_links)
        return _setup_rocm_distro_dir_impl(repository_ctx, rocm_distro)

    # Use hermetic redistributable (default: gfx908 for MI100)
    rocm_distro_version = repository_ctx.os.environ.get(_ROCM_DISTRO_VERSION, "rocm_7.10.0_gfx90X")

    if rocm_distro_version not in rocm_redist:
        fail("Unknown ROCM_DISTRO_VERSION: {}. Available versions: {}".format(
            rocm_distro_version,
            ", ".join(rocm_redist.keys())
        ))

    repository_ctx.report_progress("Downloading hermetic ROCm distribution: {}".format(rocm_distro_version))
    return _setup_rocm_distro_dir_impl(repository_ctx, rocm_redist[rocm_distro_version])

def _hipcc_autoconf_impl(repository_ctx):
    """Creates the repository containing files set up to build with ROCm."""

    tpl_paths = {labelname: _tpl_path(repository_ctx, labelname) for labelname in [
        "rocm:BUILD",
        "rocm:build_defs.bzl",
    ]}

    rocm_config = _setup_rocm_distro_dir(repository_ctx)
    rocm_version_number = int(rocm_config.rocm_version_number)
    miopen_version_number = int(rocm_config.miopen_version_number)
    hipruntime_version_number = int(rocm_config.hipruntime_version_number)

    # Copy header and library files to execroot.
    # rocm_toolkit_path
    rocm_toolkit_path = _remove_root_dir(rocm_config.rocm_toolkit_path, "rocm")
    rocm_path_relative = "rocm_dist"  # Relative to repository root
    hipcc_path_relative = rocm_path_relative + "/bin/hipcc"

    bash_bin = get_bash_bin(repository_ctx)

    clang_offload_bundler_path = rocm_toolkit_path + "/llvm/bin/clang-offload-bundler"

    repository_dict = {
        "%{rocm_root}": rocm_toolkit_path,
        "%{rocm_gpu_architectures}": str(rocm_config.amdgpu_targets),
        "%{rocm_version_number}": str(rocm_version_number),
        "%{miopen_version_number}": str(miopen_version_number),
        "%{hipruntime_version_number}": str(hipruntime_version_number),
        "%{hipcc_path}": hipcc_path_relative,
        "%{rocm_path}": rocm_path_relative,
    }

    repository_ctx.template(
        "rocm/BUILD",
        tpl_paths["rocm:BUILD"],
        repository_dict,
    )

    repository_ctx.template(
        "rocm/build_defs.bzl",
        tpl_paths["rocm:build_defs.bzl"],
        repository_dict,
    )

_ENVIRONS = [
    _TF_ROCM_AMDGPU_TARGETS,
    _ROCM_DISTRO_VERSION,
    _ROCM_DISTRO_URL,
    _ROCM_DISTRO_HASH,
    _ROCM_DISTRO_LINKS,
]

hipcc_configure = repository_rule(
    implementation = _hipcc_autoconf_impl,
    environ = _ENVIRONS + [_TF_ROCM_CONFIG_REPO],
    attrs = {
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
  name: A unique name for this workspace rule.
"""
