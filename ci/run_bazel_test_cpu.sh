# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Runs Bazel CPU tests with RBE.
#
# -e: abort script if one command fails
# -u: error if undefined variable used
# -x: log all commands
# -o history: record shell history
# -o allexport: export all functions and variables to be available to subscripts
set -exu -o history -o allexport

# Source default JAXCI environment variables.
source ci/envs/default.env

# Set up the build environment.
#source "ci/utilities/setup_build_environment.sh"

# Run Bazel CPU tests with RBE.
os=$(uname -s | awk '{print tolower($0)}')
arch=$(uname -m)

if [[ "$BAZEL_CPU_MODE" == 'build' ]]; then
    echo "Building CPU tests..."
else
    echo "Running CPU tests..."
fi

bazel $BAZEL_CPU_MODE //cc/tests/cpu:all
