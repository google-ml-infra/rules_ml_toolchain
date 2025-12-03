# Copyright 2025 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Rules for downloading mirrored archives over HTTP.

### Setup

To use these rules, load them in your `WORKSPACE` file as follows:

```python
load(
    "@rules_ml_toolchain//cc/deps:mirrored_http_archive.bzl",
    "mirrored_http_archive",
)
```
"""

load(
    "@bazel_tools//tools/build_defs/repo:utils.bzl",
    "patch",
    "read_netrc",
    "read_user_netrc",
    "update_attrs",
    "use_netrc",
)
load("//common:tar_extraction_utils.bzl", "extract_tar_with_hermetic_tar_tool")

def _get_auth(ctx, urls):
    """Given the list of URLs obtain the correct auth dict."""
    if ctx.attr.netrc:
        netrc = read_netrc(ctx, ctx.attr.netrc)
    elif "NETRC" in ctx.os.environ:
        netrc = read_netrc(ctx, ctx.os.environ["NETRC"])
    else:
        netrc = read_user_netrc(ctx)
    return use_netrc(netrc, urls, ctx.attr.auth_patterns)

def _download_remote_files(ctx, auth = None):
    for path, remote_file_urls in ctx.attr.remote_file_urls.items():
        ctx.download(
            remote_file_urls,
            path,
            canonical_id = ctx.attr.canonical_id,
            auth = _get_auth(ctx, remote_file_urls) if auth == None else auth,
            integrity = ctx.attr.remote_file_integrity.get(path, ""),
        )

def _update_sha256_attr(ctx, attrs, download_info):
    # We don't need to override the sha256 attribute if integrity is already specified.
    sha256_override = {} if ctx.attr.integrity else {"sha256": download_info.sha256}
    return update_attrs(ctx.attr, attrs.keys(), sha256_override)

def _mirrored_http_archive_impl(repository_ctx):
    """Implementation of the mirrored_http_archive rule."""

    if not repository_ctx.attr.urls:
        fail("At least one of url must be provided")

    all_urls = repository_ctx.attr.urls
    use_tars = repository_ctx.getenv("USE_MIRRORED_TAR_ARCHIVE_FILES")
    mirrored_tar_sha256 = repository_ctx.attr.mirrored_tar_sha256

    mirrored_file = None
    first_url = all_urls[0]
    mirrored_file_name = first_url.split("/")[-1]
    if (use_tars and mirrored_tar_sha256 and
        first_url.endswith(".tar.xz") and
        first_url.startswith("https://storage.googleapis.com/mirror.tensorflow.org")):
        mirrored_tar_url = first_url.replace(".tar.xz", ".tar")
        mirrored_tar_file_name = mirrored_tar_url.split("/")[-1]
        download_info = repository_ctx.download(
            url = mirrored_tar_url,
            sha256 = mirrored_tar_sha256,
            output = mirrored_tar_file_name,
            allow_fail = True,
        )
        if download_info.success:
            print("Successfully downloaded mirrored tar file: {}".format(
                mirrored_tar_url,
            ))  # buildifier: disable=print
            mirrored_file = mirrored_tar_file_name
        else:
            print("Failed to download mirrored tar file: {}".format(
                mirrored_tar_url,
            ))  # buildifier: disable=print

    if not mirrored_file:
        download_info = repository_ctx.download(
            url = all_urls,
            sha256 = repository_ctx.attr.sha256,
            output = mirrored_file_name,
        )
        mirrored_file = mirrored_file_name

    if repository_ctx.attr.strip_prefix:
        strip_prefix = repository_ctx.attr.strip_prefix
    else:
        strip_prefix = mirrored_file_name.split(".")[0]
    if first_url.endswith(".tar.xz") or first_url.endswith(".tar"):
        extract_tar_with_hermetic_tar_tool(repository_ctx, mirrored_file, strip_prefix)
    else:
        repository_ctx.extract(
            archive = mirrored_file,
            stripPrefix = strip_prefix,
        )
    repository_ctx.file(
        "BUILD.bazel",
        repository_ctx.read(repository_ctx.attr.build_file),
    )

    _download_remote_files(repository_ctx)
    patch(repository_ctx)

    repository_ctx.delete(mirrored_file)

    return _update_sha256_attr(repository_ctx, _http_archive_attrs, download_info)

_http_archive_attrs = {
    "urls": attr.string_list(),
    "sha256": attr.string(),
    "mirrored_tar_sha256": attr.string(mandatory = False),
    "integrity": attr.string(
        doc = """Expected checksum in Subresource Integrity format of the file downloaded.

This must match the checksum of the file downloaded. _It is a security risk
to omit the checksum as remote files can change._ At best omitting this
field will make your build non-hermetic. It is optional to make development
easier but either this attribute or `sha256` should be set before shipping.""",
    ),
    "build_file": attr.label(
        allow_single_file = True,
        mandatory = True,
    ),
    "netrc": attr.string(
        doc = "Location of the .netrc file to use for authentication",
    ),
    "auth_patterns": attr.string_dict(
        doc = "An optional dict mapping host names to custom authorization patterns.",
    ),
    "canonical_id": attr.string(
        doc = """A canonical id of the archive downloaded.

If specified and non-empty, bazel will not take the archive from cache,
unless it was added to the cache by a request with the same canonical id.
""",
    ),
    "strip_prefix": attr.string(),
    "patches": attr.label_list(
        default = [],
        doc =
            "A list of files that are to be applied as patches after " +
            "extracting the archive. By default, it uses the Bazel-native patch implementation " +
            "which doesn't support fuzz match and binary patch, but Bazel will fall back to use " +
            "patch command line tool if `patch_tool` attribute is specified or there are " +
            "arguments other than `-p` in `patch_args` attribute.",
    ),
    "patch_tool": attr.string(
        default = "",
        doc = "The patch(1) utility to use. If this is specified, Bazel will use the specified " +
              "patch tool instead of the Bazel-native patch implementation.",
    ),
    "patch_args": attr.string_list(
        default = ["-p0"],
        doc =
            "The arguments given to the patch tool. Defaults to -p0, " +
            "however -p1 will usually be needed for patches generated by " +
            "git. If multiple -p arguments are specified, the last one will take effect." +
            "If arguments other than -p are specified, Bazel will fall back to use patch " +
            "command line tool instead of the Bazel-native patch implementation. When falling " +
            "back to patch command line tool and patch_tool attribute is not specified, " +
            "`patch` will be used. This only affects patch files in the `patches` attribute.",
    ),
    "remote_file_urls": attr.string_list_dict(
        default = {},
        doc =
            "A map of relative paths (key) to a list of URLs (value) that are to be downloaded " +
            "and made available as overlaid files on the repo. This is useful when you want " +
            "to add WORKSPACE or BUILD.bazel files atop an existing repository. The files " +
            "are downloaded before applying the patches in the `patches` attribute and the list of URLs " +
            "should all be possible mirrors of the same file. The URLs are tried in order until one succeeds. ",
    ),
    "remote_file_integrity": attr.string_dict(
        default = {},
        doc =
            "A map of file relative paths (key) to its integrity value (value). These relative paths should map " +
            "to the files (key) in the `remote_file_urls` attribute.",
    ),
    "xz_tool": attr.label(
        default = Label("@xz//:bin/xz"),
        allow_single_file = True,
    ),
    "tar_tool": attr.label(
        default = Label("@tar//:bin/tar"),
        allow_single_file = True,
    ),
}

mirrored_http_archive = repository_rule(
    implementation = _mirrored_http_archive_impl,
    attrs = _http_archive_attrs,
    doc = """Downloads a compressed archive file, decompresses it,
        and makes its targets available for binding. For tar.xz it can use a
        mirrored tar if mirrored_tar_sha256 is provided and the .tar file is
        available in the mirror.""",
)
