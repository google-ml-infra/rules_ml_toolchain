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

    if not url:
        fail("ROCm URL must be provided")
    if not sha256:
        fail("ROCm SHA256 hash must be provided")

    # Create marker file
    repository_ctx.file(".index")

    # Download and extract the package
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
