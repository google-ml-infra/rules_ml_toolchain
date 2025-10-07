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

"""Rules for downloading files and archives over HTTP.

### Setup

To use these rules, load them in your `WORKSPACE` file as follows:

```python
load(
    "@rules_ml_toolchain//cc/deps:llvm_http_archive.bzl",
    "llvm_http_archive",
)
```

These rules are improved versions of the native http rules and will eventually
replace the native rules.
"""

load(
    "@bazel_tools//tools/build_defs/repo:utils.bzl",
    "patch",
    "read_netrc",
    "read_user_netrc",
    "update_attrs",
    "use_netrc",
)
load(
    "//cc:constants.bzl",
    "USE_HERMETIC_CC_TOOLCHAIN",
    "USE_HERMETIC_CC_TOOLCHAIN_DEFAULT_VALUE",
)
load("//common:tar_extraction_utils.bzl", "extract_tar_with_non_hermetic_tar_tool")
load(
    "//third_party/remote_config:common.bzl",
    "get_host_environ",
)

_URL_DOC = """A URL to a file that will be made available to Bazel.

This must be a file, http or https URL. Redirections are followed.
Authentication is not supported.

More flexibility can be achieved by the urls parameter that allows
to specify alternative URLs to fetch from."""

_URLS_DOC = """A list of URLs to a file that will be made available to Bazel.

Each entry must be a file, http or https URL. Redirections are followed.
Authentication is not supported.

URLs are tried in order until one succeeds, so you should list local mirrors first.
If all downloads fail, the rule will fail."""

def buildfile(ctx):
    """Utility function for writing a BUILD file.

    This rule is intended to be used in the implementation function of a
    repository rule.
    It assumes the parameters `name` and `build_file` to
    be present in `ctx.attr`.

    Args:
      ctx: The repository context of the repository rule calling this utility
        function.
    """

    ctx.file("BUILD.bazel", ctx.read(ctx.attr.build_file))

def extract_llvm_version(text):
    start_marker = "llvm"
    end_marker = "_"

    start_index = text.find(start_marker)
    if start_index == -1:
        return None  # "llvm" not found

    version_start = start_index + len(start_marker)

    end_index = text.find(end_marker, version_start)
    if end_index == -1:
        return None  # "_" not found after "llvm"

    version_str = text[version_start:end_index]

    return version_str

def _create_empty_build_file(ctx):
    ctx.file("BUILD", "# Empty BUILD file for non-hermetic builds")

def _create_version_file(ctx, major_version):
    ctx.file(
        "version.bzl",
        "VERSION = \"{}\"".format(major_version),
    )

def _get_all_urls(ctx):
    """Returns all urls provided via the url or urls attributes.

    Also checks that at least one url is provided."""
    if not ctx.attr.urls:
        fail("At least one of url must be provided")

    return ctx.attr.urls

def _download_remote_files(ctx, auth = None):
    """Utility function for downloading remote files.

    This rule is intended to be used in the implementation function of
    a repository rule. It assumes the parameters `remote_file_urls` and
    `remote_file_integrity` to be present in `ctx.attr`.

    Args:
      ctx: The repository context of the repository rule calling this utility
        function.
      auth: An optional dict specifying authentication information for some of the URLs.
    """
    for path, remote_file_urls in ctx.attr.remote_file_urls.items():
        ctx.download(
            remote_file_urls,
            path,
            canonical_id = ctx.attr.canonical_id,
            auth = _get_auth(ctx, remote_file_urls) if auth == None else auth,
            integrity = ctx.attr.remote_file_integrity.get(path, ""),
        )

_AUTH_PATTERN_DOC = """An optional dict mapping host names to custom authorization patterns.

If a URL's host name is present in this dict the value will be used as a pattern when
generating the authorization header for the http request. This enables the use of custom
authorization schemes used in a lot of common cloud storage providers.

The pattern currently supports 2 tokens: <code>&lt;login&gt;</code> and
<code>&lt;password&gt;</code>, which are replaced with their equivalent value
in the netrc file for the same host name. After formatting, the result is set
as the value for the <code>Authorization</code> field of the HTTP request.

Example attribute and netrc for a http download to an oauth2 enabled API using a bearer token:

<pre>
auth_patterns = {
    "storage.cloudprovider.com": "Bearer &lt;password&gt;"
}
</pre>

netrc:

<pre>
machine storage.cloudprovider.com
        password RANDOM-TOKEN
</pre>

The final HTTP request would have the following header:

<pre>
Authorization: Bearer RANDOM-TOKEN
</pre>
"""

def _get_auth(ctx, urls):
    """Given the list of URLs obtain the correct auth dict."""
    if ctx.attr.netrc:
        netrc = read_netrc(ctx, ctx.attr.netrc)
    elif "NETRC" in ctx.os.environ:
        netrc = read_netrc(ctx, ctx.os.environ["NETRC"])
    else:
        netrc = read_user_netrc(ctx)
    return use_netrc(netrc, urls, ctx.attr.auth_patterns)

def _use_hermetic_toolchains(ctx):
    return get_host_environ(ctx, USE_HERMETIC_CC_TOOLCHAIN, USE_HERMETIC_CC_TOOLCHAIN_DEFAULT_VALUE) == "1"

def _is_supported_platform(ctx):
    url = ctx.attr.urls[0].lower()

    if ctx.os.name not in url:
        return False

    if ctx.os.arch == "amd64":
        archs = ["amd64", "x86_64", "x64", "x86-64"]
    elif ctx.os.arch == "aarch64":
        archs = ["aarch64", "arm64"]
    else:
        archs = [ctx.os.arch]

    for arch in archs:
        if arch in url:
            return True

    return False

def _update_sha256_attr(ctx, attrs, download_info):
    # We don't need to override the sha256 attribute if integrity is already specified.
    sha256_override = {} if ctx.attr.integrity else {"sha256": download_info.sha256}
    return update_attrs(ctx.attr, attrs.keys(), sha256_override)

def _llvm_http_archive_impl(ctx):
    """Implementation of the llvm_http_archive rule."""

    if not _use_hermetic_toolchains(ctx) or not _is_supported_platform(ctx):
        _create_version_file(ctx, "")
        _create_empty_build_file(ctx)
        return ctx.attr

    all_urls = _get_all_urls(ctx)
    use_tars = ctx.getenv("USE_LLVM_TAR_ARCHIVE_FILES")
    mirrored_tar_sha256 = ctx.attr.mirrored_tar_sha256
    auth = _get_auth(ctx, all_urls)

    llvm_file = None
    first_url = all_urls[0]
    llvm_file_name = first_url.split("/")[-1]
    if (use_tars and mirrored_tar_sha256 and
        first_url.endswith(".tar.xz") and
        first_url.startswith("https://storage.googleapis.com/mirror.tensorflow.org")):
        mirrored_tar_url = first_url.replace(".tar.xz", ".tar")
        mirrored_tar_llvm_file_name = mirrored_tar_url.split("/")[-1]
        download_info = ctx.download(
            url = mirrored_tar_url,
            sha256 = mirrored_tar_sha256,
            output = mirrored_tar_llvm_file_name,
            canonical_id = ctx.attr.canonical_id,
            auth = auth,
            allow_fail = True,
            integrity = ctx.attr.integrity,
        )
        if download_info.success:
            print("Successfully downloaded mirrored tar file: {}".format(
                mirrored_tar_url,
            ))  # buildifier: disable=print
            llvm_file = mirrored_tar_llvm_file_name
        else:
            print("Failed to download mirrored tar file: {}".format(
                mirrored_tar_url,
            ))  # buildifier: disable=print

    if not llvm_file:
        download_info = ctx.download(
            url = all_urls,
            sha256 = ctx.attr.sha256,
            output = llvm_file_name,
        )
        llvm_file = llvm_file_name

    if ctx.attr.strip_prefix:
        strip_prefix = ctx.attr.strip_prefix
    else:
        strip_prefix = llvm_file_name.split(".")[0]
    if first_url.endswith(".tar.xz") or first_url.endswith(".tar"):
        extract_tar_with_non_hermetic_tar_tool(ctx, llvm_file, strip_prefix)
    else:
        ctx.extract(
            archive = llvm_file,
            stripPrefix = strip_prefix,
        )
    buildfile(ctx)

    _download_remote_files(ctx)

    patch(ctx, auth = auth)

    llvm_version = extract_llvm_version(str(ctx.attr.build_file))

    if llvm_version:
        _create_version_file(ctx, llvm_version)

    ctx.delete(llvm_file)

    return _update_sha256_attr(ctx, _llvm_http_archive_attrs, download_info)

_llvm_http_archive_attrs = {
    "urls": attr.string_list(doc = _URLS_DOC),
    "sha256": attr.string(
        doc = """The expected SHA-256 of the file downloaded.

This must match the SHA-256 of the file downloaded. _It is a security risk
to omit the SHA-256 as remote files can change._ At best omitting this
field will make your build non-hermetic. It is optional to make development
easier but either this attribute or `integrity` should be set before shipping.""",
    ),
    "mirrored_tar_sha256": attr.string(
        mandatory = False,
        doc = "The expected SHA-256 of the mirrored .tar archive.",
    ),
    "integrity": attr.string(
        doc = """Expected checksum in Subresource Integrity format of the file downloaded.

This must match the checksum of the file downloaded. _It is a security risk
to omit the checksum as remote files can change._ At best omitting this
field will make your build non-hermetic. It is optional to make development
easier but either this attribute or `sha256` should be set before shipping.""",
    ),
    "netrc": attr.string(
        doc = "Location of the .netrc file to use for authentication",
    ),
    "auth_patterns": attr.string_dict(
        doc = _AUTH_PATTERN_DOC,
    ),
    "canonical_id": attr.string(
        doc = """A canonical id of the archive downloaded.

If specified and non-empty, bazel will not take the archive from cache,
unless it was added to the cache by a request with the same canonical id.
""",
    ),
    "strip_prefix": attr.string(
        doc = """A directory prefix to strip from the extracted files.

Many archives contain a top-level directory that contains all of the useful
files in archive. Instead of needing to specify this prefix over and over
in the `build_file`, this field can be used to strip it from all of the
extracted files.

For example, suppose you are using `foo-lib-latest.zip`, which contains the
directory `foo-lib-1.2.3/` under which there is a `WORKSPACE` file and are
`src/`, `lib/`, and `test/` directories that contain the actual code you
wish to build. Specify `strip_prefix = "foo-lib-1.2.3"` to use the
`foo-lib-1.2.3` directory as your top-level directory.

Note that if there are files outside of this directory, they will be
discarded and inaccessible (e.g., a top-level license file). This includes
files/directories that start with the prefix but are not in the directory
(e.g., `foo-lib-1.2.3.release-notes`). If the specified prefix does not
match a directory in the archive, Bazel will return an error.""",
    ),
    "add_prefix": attr.string(
        default = "",
        doc = """Destination directory relative to the repository directory.

The archive will be unpacked into this directory, after applying `strip_prefix`
(if any) to the file paths within the archive. For example, file
`foo-1.2.3/src/foo.h` will be unpacked to `bar/src/foo.h` if `add_prefix = "bar"`
and `strip_prefix = "foo-1.2.3"`.""",
    ),
    "type": attr.string(
        doc = """The archive type of the downloaded file.

By default, the archive type is determined from the file extension of the
URL. If the file has no extension, you can explicitly specify one of the
following: `"zip"`, `"war"`, `"aar"`, `"tar"`, `"tar.gz"`, `"tgz"`,
`"tar.xz"`, `"txz"`, `"tar.zst"`, `"tzst"`, `tar.bz2`, `"ar"`, or `"deb"`.""",
    ),
    "patches": attr.label_list(
        default = [],
        doc =
            "A list of files that are to be applied as patches after " +
            "extracting the archive. By default, it uses the Bazel-native patch implementation " +
            "which doesn't support fuzz match and binary patch, but Bazel will fall back to use " +
            "patch command line tool if `patch_tool` attribute is specified or there are " +
            "arguments other than `-p` in `patch_args` attribute.",
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
    "remote_patches": attr.string_dict(
        default = {},
        doc =
            "A map of patch file URL to its integrity value, they are applied after extracting " +
            "the archive and before applying patch files from the `patches` attribute. " +
            "It uses the Bazel-native patch implementation, you can specify the patch strip " +
            "number with `remote_patch_strip`",
    ),
    "remote_patch_strip": attr.int(
        default = 0,
        doc =
            "The number of leading slashes to be stripped from the file name in the remote patches.",
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
    "patch_cmds": attr.string_list(
        default = [],
        doc = "Sequence of Bash commands to be applied on Linux/Macos after patches are applied.",
    ),
    "patch_cmds_win": attr.string_list(
        default = [],
        doc = "Sequence of Powershell commands to be applied on Windows after patches are " +
              "applied. If this attribute is not set, patch_cmds will be executed on Windows, " +
              "which requires Bash binary to exist.",
    ),
    "build_file": attr.label(
        allow_single_file = True,
        mandatory = True,
        doc =
            "The file to use as the BUILD file for this repository." +
            "This attribute is an absolute label (use '@//' for the main " +
            "repo). The file does not need to be named BUILD, but can " +
            "be (something like BUILD.new-repo-name may work well for " +
            "distinguishing it from the repository's actual BUILD files. ",
    ),
    "xz_tool": attr.label(
        default = Label("@xz//:bin/xz"),
        allow_single_file = True,
        doc = "The hermetic xz tool to extract tar.xz archives.",
    ),
    "tar_tool": attr.label(
        default = Label("@tar//:bin/tar"),
        allow_single_file = True,
        doc = "The hermetic tar tool to extract tar archives.",
    ),
}

llvm_http_archive = repository_rule(
    implementation = _llvm_http_archive_impl,
    attrs = _llvm_http_archive_attrs,
    doc =
        """Downloads a Bazel repository as a compressed archive file, decompresses it,
and makes its targets available for binding.

It supports the following file extensions: `"zip"`, `"war"`, `"aar"`, `"tar"`,
`"tar.gz"`, `"tgz"`, `"tar.xz"`, `"txz"`, `"tar.zst"`, `"tzst"`, `tar.bz2`, `"ar"`,
or `"deb"`.

Examples:
  Suppose the current repository contains the source code for a chat program,
  rooted at the directory `~/chat-app`. It needs to depend on an SSL library
  which is available from http://example.com/openssl.zip. This `.zip` file
  contains the following directory structure:

  ```
  WORKSPACE
  src/
    openssl.cc
    openssl.h
  ```

  In the local repository, the user creates a `openssl.BUILD` file which
  contains the following target definition:

  ```python
  cc_library(
      name = "openssl-lib",
      srcs = ["src/openssl.cc"],
      hdrs = ["src/openssl.h"],
  )
  ```

  Targets in the `~/chat-app` repository can depend on this target if the
  following lines are added to `~/chat-app/WORKSPACE`:

  ```python
  load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

  http_archive(
      name = "my_ssl",
      urls = ["http://example.com/openssl.zip"],
      sha256 = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
      build_file = "@//:openssl.BUILD",
  )
  ```

  Then targets would specify `@my_ssl//:openssl-lib` as a dependency.
""",
)
