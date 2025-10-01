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

load("//common:tar_extraction_utils.bzl", "extract_tar_with_non_hermetic_tar_tool")

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
       extract_tar_with_non_hermetic_tar_tool(repository_ctx, mirrored_file, strip_prefix)
    else:
        repository_ctx.extract(
            archive = mirrored_file,
            stripPrefix = strip_prefix,
        )
    repository_ctx.file(
        "BUILD.bazel", 
        repository_ctx.read(repository_ctx.attr.build_file),
    )

    repository_ctx.delete(mirrored_file)

mirrored_http_archive = repository_rule(
    implementation = _mirrored_http_archive_impl,
    attrs = {
        "urls": attr.string_list(),
        "sha256": attr.string(),
        "mirrored_tar_sha256": attr.string(mandatory = False),
        "build_file": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        "strip_prefix": attr.string(),
    },
    doc = """Downloads a compressed archive file, decompresses it,
        and makes its targets available for binding. For tar.xz it can use a
        mirrored tar if mirrored_tar_sha256 is provided and the .tar file is
        available in the mirror.""",
)

