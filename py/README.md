# Hermetic Python Toolchains for ML

This package provides Bazel rules and repository configurations for hermetic Python interpreters, locked PyPI dependencies, and C++/Python binding packaging (`rules_pywrap`) in ML projects.

Python hermetic builds benefits:
* Reproducibility: Uses pinned, redistributable CPython interpreters and locked `requirements_lock` files across Linux, macOS, and Windows.
* Consistency: Eliminates host Python version mismatches and system site-packages leakage.
* C++/Python Interoperability: Includes [Pywrap rules](rules_pywrap/README.md) (`pybind_extension`, `pywrap_library`) to build `pybind11` extensions without One Definition Rule (ODR) violations and with shared common libraries.

## Configure Python toolchains in rules_ml_toolchain

`rules_python` is patched with the patch files in [`third_party/rules_python`](../third_party/rules_python/) through a `single_version_override`. Overrides only take effect in the root module, and `single_version_override` only accepts patch files from the root module's own source tree, so your project has to declare the `single_version_override` itself: copy the patch files into your own project first and point `patches` at your copies. The example below assumes the copies are in `third_party/rules_python/`, next to a `BUILD.bazel` file (it can be empty) so that the labels resolve.

Configure `rules_python` (including the `rules_ml_toolchain` patches required for free-threaded builds and lockfile compatibility) and `python_version_ext` in your `MODULE.bazel` file:

```starlark
bazel_dep(name = "rules_ml_toolchain")
archive_override(
    module_name = "rules_ml_toolchain",
    integrity = "sha256-bywqV064uobGw+nzpAUoTZyRWvpn6m4SwhCoFnY98Sk=",
    strip_prefix = "rules_ml_toolchain-ec70529c9a611b364f12d67f61f083524e445431",
    urls = [
        "https://github.com/google-ml-infra/rules_ml_toolchain/archive/ec70529c9a611b364f12d67f61f083524e445431.tar.gz",
    ],
)
bazel_dep(name = "rules_python", version = "1.8.5")
bazel_dep(name = "pybind11_bazel", version = "2.13.6")

# Uses your own copies of rules_ml_toolchain's third_party/rules_python/*.patch files (see above).
single_version_override(
    module_name = "rules_python",
    patch_strip = 1,
    patches = [
        "//third_party/rules_python:rules_python_scope.patch",
        "//third_party/rules_python:rules_python_freethreaded.patch",
        "//third_party/rules_python:rules_python_versions.patch",
        "//third_party/rules_python:rules_python_pip_version.patch",
    ],
    version = "1.8.5",
)

python_version_ext = use_extension(
    "@rules_ml_toolchain//extensions:python_version.bzl",
    "python_version_ext",
)
use_repo(python_version_ext, "python_version_repo")

python = use_extension("@rules_python//python/extensions:python.bzl", "python")
python.defaults(
    python_version = "3.11",
    python_version_env = "HERMETIC_PYTHON_VERSION",
)
python.toolchain(python_version = "3.11")
python.toolchain(python_version = "3.12")
python.toolchain(python_version = "3.13")
python.toolchain(python_version = "3.14")
```

## Configure the Python version and custom interpreter

By default, Python `3.11` is used (or `3.13` as configured in `.bazelrc`). You can select the Python version via the `HERMETIC_PYTHON_VERSION` repository environment variable in `.bazelrc` or on the command line:

```
build --repo_env=HERMETIC_PYTHON_VERSION=3.13
```

Supported Python versions and mode requirements:

| Version   | Description                           | Bzlmod (`MODULE.bazel`)                                                                                          | `WORKSPACE` (`python_init_repositories`)                                                                         |
|-----------|---------------------------------------|------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------|
| `3.11`    | CPython 3.11                          | `--repo_env=HERMETIC_PYTHON_VERSION=3.11`                                                                        | `--repo_env=HERMETIC_PYTHON_VERSION=3.11`                                                                        |
| `3.12`    | CPython 3.12                          | `--repo_env=HERMETIC_PYTHON_VERSION=3.12`                                                                        | `--repo_env=HERMETIC_PYTHON_VERSION=3.12`                                                                        |
| `3.13`    | CPython 3.13                          | `--repo_env=HERMETIC_PYTHON_VERSION=3.13`                                                                        | `--repo_env=HERMETIC_PYTHON_VERSION=3.13`                                                                        |
| `3.14`    | CPython 3.14                          | `--repo_env=HERMETIC_PYTHON_VERSION=3.14`                                                                        | `--repo_env=HERMETIC_PYTHON_VERSION=3.14`                                                                        |
| `3.13-ft` | CPython 3.13 free-threaded (`cp313t`) | Requires patched `rules_python`: `--repo_env=HERMETIC_PYTHON_VERSION=3.13` + `--@rules_python//python/config_settings:py_freethreaded="yes"` | `--repo_env=HERMETIC_PYTHON_VERSION=3.13-ft` + `--@rules_python//python/config_settings:py_freethreaded="yes"` |
| `3.14-ft` | CPython 3.14 free-threaded (`cp314t`) | Requires patched `rules_python`: `--repo_env=HERMETIC_PYTHON_VERSION=3.14` + `--@rules_python//python/config_settings:py_freethreaded="yes"` | `--repo_env=HERMETIC_PYTHON_VERSION=3.14-ft` + `--@rules_python//python/config_settings:py_freethreaded="yes"` |

> **Note on free-threaded Python (`-ft`):** The `-ft` suffix in `HERMETIC_PYTHON_VERSION` (e.g., `3.13-ft`, `3.14-ft`) is parsed by `python_init_repositories` / `python_register_toolchain` in **`WORKSPACE` mode** to select both the free-threaded interpreter and the `*_ft.txt` lockfile. Under **Bzlmod**, `@rules_python//python/extensions:python.bzl` only accepts standard version strings (`3.13`, `3.14`) and switches to the free-threaded interpreter when `rules_python` is patched and `--@rules_python//python/config_settings:py_freethreaded="yes"` is passed.

### Custom Python interpreter archive (`WORKSPACE` mode only)

> **Note:** Custom interpreter environment variables (`HERMETIC_PYTHON_URL`, `HERMETIC_PYTHON_SHA256`, and `HERMETIC_PYTHON_PREFIX`) are currently supported **only in `WORKSPACE` mode** via `python_init_repositories()` and `python_register_toolchain()` (Bzlmod support is tracked as a `TODO` in [`MODULE.bazel`](../MODULE.bazel)).

To use a custom-built CPython archive in `WORKSPACE` mode (for example, an ASan- or TSan-instrumented Python build), specify `HERMETIC_PYTHON_URL`, `HERMETIC_PYTHON_SHA256`, and `HERMETIC_PYTHON_PREFIX`:

```
build --repo_env=HERMETIC_PYTHON_VERSION=3.13
build --repo_env=HERMETIC_PYTHON_URL="https://storage.googleapis.com/ml-sysroot-testing/python/cpython-3.13.x-asan-shared-linux-x86_64-llvm-18.1.8.tar.gz"
build --repo_env=HERMETIC_PYTHON_SHA256=cc7354abad5ab5b87aae3c870e510860c9ffefcd3d8f6c3e02129aaf9d30a5bb
build --repo_env=HERMETIC_PYTHON_PREFIX="cpython-3.13.x-asan-shared-linux-x86_64-llvm-18.1.8/"
```

## Building C++/Python bindings (`rules_pywrap`)

`rules_ml_toolchain` includes the `rules_pywrap` ruleset under [`//py/rules_pywrap`](rules_pywrap/README.md) for building `pybind11` extensions and aggregating shared C++ dependencies across multiple Python extension modules:

* `pybind_extension` / `python_extension`: Declares an individual Python C++ extension module.
* `pywrap_library`: Aggregates multiple `pybind_extension` targets and links shared C++ dependencies into common dynamic libraries to prevent ODR violations and reduce binary size.
* `pywrap_common_library` & `pywrap_binaries`: Exposes the shared libraries and extension binaries produced by `pywrap_library`.

Enable pywrap rules via `--repo_env=USE_PYWRAP_RULES=True`. See [`rules_pywrap/README.md`](rules_pywrap/README.md) for detailed usage and examples.

## Run Python toolchain tests

Run the hermetic Python and `pybind11` / `pywrap` test suites with:

```bash
bazel test --repo_env=USE_PYWRAP_RULES=True //py/tests/pybind:all //py/tests/pybind_external:all
```

To run with Bzlmod enabled:

```bash
bazel test --config=bzlmod --repo_env=USE_PYWRAP_RULES=True //py/tests/pybind:all //py/tests/pybind_external:all
```
