"""Macro for downloading ROCm redistributable using http_archive."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Default ROCm distro (gfx908, ROCm 7.12.0)
_DEFAULT_ROCM_URL = "https://repo.amd.com/rocm/tarball/therock-dist-linux-gfx908-7.12.0.tar.gz"
_DEFAULT_ROCM_SHA256 = "8645100bd43761253114f175a6b5e5e928a72a437094e9e35d750ea089d41d6c"
_DEFAULT_ROCM_STRIP_PREFIX = ""  # ROCm files are at archive root

def rocm_redist_download(
        name,
        url = _DEFAULT_ROCM_URL,
        sha256 = _DEFAULT_ROCM_SHA256,
        strip_prefix = _DEFAULT_ROCM_STRIP_PREFIX):
    """Downloads ROCm redistributable using http_archive.

    This is a simple wrapper around http_archive for downloading ROCm
    within rules_ml_toolchain.

    Args:
        name: Name of the repository.
        url: URL of the ROCm tarball (default: gfx908 ROCm 7.12.0).
        sha256: SHA256 hash of the tarball.
        strip_prefix: Prefix to strip from extracted files.
    """
    http_archive(
        name = name,
        urls = [url],
        sha256 = sha256,
        strip_prefix = strip_prefix,
        build_file_content = """
# Export a filegroup pointing to all files
# When hipcc_configure resolves this label's path, it gets the repository directory
filegroup(
    name = "rocm_dist",
    srcs = glob(["**/*"]),
    visibility = ["//visibility:public"],
)
""",
    )
