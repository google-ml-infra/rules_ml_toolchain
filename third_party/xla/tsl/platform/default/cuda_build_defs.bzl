# Copyright 2015 The TensorFlow Authors. All Rights Reserved.
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

"""Open source build configurations for CUDA."""

load(
    "@local_config_cuda//cuda:build_defs.bzl",
    _if_cuda_is_configured = "if_cuda_is_configured",
    _if_cuda_newer_than = "if_cuda_newer_than",
    _is_cuda_configured = "is_cuda_configured",
)

# We perform this indirection so that the copybara tool can distinguish this
# macro from others provided by the same file.
def if_cuda_is_configured(x, no_cuda = []):
    return _if_cuda_is_configured(x, no_cuda)

# We perform this indirection so that the copybara tool can distinguish this
# macro from others provided by the same file.
def is_cuda_configured():
    return _is_cuda_configured()

# Constructs rpath linker flags for use with nvidia wheel-packaged libs
# avaialble from PyPI. Two paths are needed because symbols are used from
# both the root of the TensorFlow installation directory as well as from
# various pywrap libs within the 'python' subdir.
def cuda_rpath_flags(relpath):
    return [
        "-Wl,-rpath='$$ORIGIN/../../" + relpath + "'",
        "-Wl,-rpath='$$ORIGIN/../" + relpath + "'",
    ]

def if_cuda_newer_than(wanted_ver, if_true, if_false = []):
    return _if_cuda_newer_than(wanted_ver, if_true, if_false)
