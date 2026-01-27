#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Set by GH actions, see
# https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables
readonly TAG=$1
# The prefix is chosen to match what GitHub generates for source archives.
# This guarantees that users can easily switch from a released artifact to a source archive
# with minimal differences in their code (e.g. strip_prefix remains the same)
readonly PREFIX="rules_ml_toolchain-${TAG}"
readonly ARCHIVE="${PREFIX}.tar.gz"

# NB: configuration for 'git archive' is in /.gitattributes
git archive --format=tar --prefix=${PREFIX}/ ${TAG} | gzip > $ARCHIVE
SHA=$(shasum -a 256 $ARCHIVE | awk '{print $1}')

# The stdout of this program will be used as the top of the release notes for this release.
cat << EOF
## Using Bzlmod, just add to your \`MODULE.bazel\` file:

\`\`\`starlark
bazel_dep(name = "rules_ml_toolchain", version = "${TAG}")

register_toolchains("@rules_ml_toolchain//cc:linux_x86_64_linux_x86_64")
register_toolchains("@rules_ml_toolchain//cc:linux_aarch64_linux_aarch64")
\`\`\`

## Using WORKSPACE, add to your \`WORKSPACE\` file:

\`\`\`starlark
http_archive(
    name = "rules_ml_toolchain",
    sha256 = "${SHA}",
    strip_prefix = "${PREFIX}",
    urls = [
        "https://github.com/google-ml-infra/rules_ml_toolchain/releases/download/${TAG}/${ARCHIVE}",
    ],
)

load(
    "@rules_ml_toolchain//cc/deps:cc_toolchain_deps.bzl",
    "cc_toolchain_deps",
)

cc_toolchain_deps()

register_toolchains("@rules_ml_toolchain//cc:linux_x86_64_linux_x86_64")
register_toolchains("@rules_ml_toolchain//cc:linux_aarch64_linux_aarch64")
\`\`\`

EOF
