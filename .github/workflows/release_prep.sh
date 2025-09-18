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

# The stdout of this program will be used as the top of the release notes for this release.
cat << EOF
## Using Bzlmod, just add to your \`MODULE.bazel\` file:

\`\`\`starlark
bazel_dep(name = "rules_ml_toolchain", version = "${TAG}")
\`\`\`
EOF
