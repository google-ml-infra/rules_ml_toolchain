#!/bin/bash
# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
#
# This tool queries all registered toolchains under //cc/impls and calls
# cc/gen_crosstool_cppmap.sh for each of them.
#
# Note that this requires that all toolchains need to be configurable on the system
# where this command is getting executed since gen_crosstool_cppmap.sh calls bazel cquery.
#
# Usage: cc/update_all_crosstool_cppmaps.sh


set -euo pipefail
readonly SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

bazel query 'kind(cc_toolchain, //cc/impls/...)' | grep :toolchain | while read target; do 
  crosstool_cppmap="${SCRIPT_DIR}/..${target/\//}"
  crosstool_cppmap="${crosstool_cppmap/:toolchain//crosstool.cppmap}"
  ${SCRIPT_DIR}/gen_crosstool_cppmap.sh $target >${crosstool_cppmap}
done
