"""Repository rule for downloading hermetic ROCm distribution."""

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

    rocm_root = "invalid"

    # If url and sha256 are provided, download and extract the distribution
    if url and sha256:
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
        rocm_root = _DISTRIBUTION_PATH
    else:
        # Create an empty rocm_dist directory for dummy repos
        # This allows hipcc_configure to symlink it without errors
        repository_ctx.file(_DISTRIBUTION_PATH + "/.keep", "")

    # Create BUILD file from template
    repository_ctx.template(
        "BUILD",
        _tpl_path(repository_ctx, "rocm_dist.BUILD.tpl"),
        {
            "%{rocm_root}": rocm_root,
        },
    )

rocm_hermetic_download = repository_rule(
    implementation = _rocm_hermetic_download_impl,
    attrs = {
        "url": attr.string(
            default = "",
            doc = "URL of the ROCm redistributable tarball to download. If not set, creates a dummy BUILD file.",
        ),
        "sha256": attr.string(
            default = "",
            doc = "SHA256 hash of the ROCm redistributable tarball. If not set, creates a dummy BUILD file.",
        ),
    },
)
