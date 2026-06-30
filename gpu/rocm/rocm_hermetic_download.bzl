"""Repository rule for downloading hermetic ROCm distribution."""

# Default ROCm distribution for testing
# ROCm 7.12.0 for gfx908 (from AMD repository)
ROCM_URL = "https://repo.amd.com/rocm/tarball/therock-dist-linux-gfx908-7.12.0.tar.gz"
ROCM_SHA256 = "8645100bd43761253114f175a6b5e5e928a72a437094e9e35d750ea089d41d6c"

_DISTRIBUTION_PATH = "rocm_dist"

def _tpl_path(repository_ctx, labelname):
    """Returns the path to a template file."""
    return repository_ctx.path(Label("//gpu/rocm:{}".format(labelname)))

def _get_file_name(url):
    """Extracts filename from URL."""
    last_slash_index = url.rfind("/")
    return url[last_slash_index + 1:]

def _rocm_hermetic_download_impl(repository_ctx):
    """Downloads and extracts ROCm hermetic distribution."""
    url = repository_ctx.attr.url
    sha256 = repository_ctx.attr.sha256

    repository_ctx.file(".index")

    file_name = _get_file_name(url)
    print("Downloading {}".format(url))
    repository_ctx.report_progress("Downloading and extracting {}, expected hash is {}".format(url, sha256))

    repository_ctx.download_and_extract(
        url = url,
        output = _DISTRIBUTION_PATH,
        sha256 = sha256,
        type = "zip" if url.endswith(".whl") else "",
    )

    repository_ctx.delete(file_name)

    # Create BUILD file from template
    repository_ctx.template(
        "BUILD",
        _tpl_path(repository_ctx, "rocm_dist.BUILD.tpl"),
        {
            "%{rocm_root}": _DISTRIBUTION_PATH,
        },
    )

rocm_hermetic_download = repository_rule(
    implementation = _rocm_hermetic_download_impl,
    attrs = {
        "url": attr.string(
            mandatory = True,
            doc = "URL of the ROCm redistributable tarball to download",
        ),
        "sha256": attr.string(
            mandatory = True,
            doc = "SHA256 hash of the ROCm redistributable tarball",
        ),
    },
)
