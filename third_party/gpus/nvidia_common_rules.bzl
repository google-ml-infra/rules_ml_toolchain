# Copyright 2025 The TensorFlow Authors. All rights reserved.
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

"""DEPRECATED: use //gpu:nvidia_common_rules.bzl instead."""

load("//gpu:nvidia_common_rules.bzl", _cuda_rpath_flags = "cuda_rpath_flags")

# This function is kept only for the backwards-compatibility purposes.
# TODO(ybaturina): remove the file when all ML projects use new repo structure.
def cuda_rpath_flags(relpath):
    return _cuda_rpath_flags(relpath)
