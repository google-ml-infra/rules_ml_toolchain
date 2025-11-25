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
# This tool creates a crosstool.cppmap Clang header modules map file for the toolchain.
# 
# Usage:
# cc/gen_crosstool_cppmap.sh //cc/impls/linux_x86_64_linux_x86_64_cuda:toolchain > cc/impls/linux_x86_64_linux_x86_64_cuda/crosstool.cppmap

readonly TOOLCHAIN_TARGET=$1
shift


#echo '# This file is auto-generated'
echo 'module "crosstool" [system] {'
# This will output more files than we actually need, but for our purpose of using the header module map 
# for the layering check that doesn't matter.
bazel cquery --output=starlark '--starlark:expr="\n".join([f.path for f in target.files.to_list() if len(f.owner.workspace_name) == 0])' $TOOLCHAIN_TARGET \
  | grep -E '\.h$' | while read f; do
  # These are the files that live in the rules_ml_toolchain repo. We need to prefix them with the path where they
  # are being mapped to in the user's repo.
  echo "  textual header \"external/rules_ml_toolchain/$f\""
done
bazel cquery --output=starlark '--starlark:expr="\n".join([f.path for f in target.files.to_list() if len(f.owner.workspace_name) > 0])' $TOOLCHAIN_TARGET \
  | grep -E '/include/|cc/cuda/' | while read f; do
  echo "  textual header \"$f\""
done
echo '}'
