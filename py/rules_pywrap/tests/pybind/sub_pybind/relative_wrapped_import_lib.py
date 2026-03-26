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

from .nested_wrapped_pybind import nested_pybind_func
from ..pybind_wrapped.sub._sub_private import _sub_private_private_func

def call_nested_pyind_func(x):
  return nested_pybind_func(x)

def sub_sub_private_func(x):
  return _sub_private_private_func(x)