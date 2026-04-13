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

import unittest
from py.tests.pybind import pybind as regular
from py.tests.pybind import pybind_copy as regular_copy
from py.tests.pybind import pybind_with_starlark_only as regular_with_starlark_only

class PybindTest(unittest.TestCase):
  def test_pybind_first(self):
    print("1: regular.second_global_func")
    self.assertEqual(regular.second_global_func(), 3)
    print("2: regular_copy.second_global_func")
    self.assertEqual(regular_copy.second_global_func(), 3)
    print("3: sixth_func.sixth_func")
    self.assertEqual(regular_with_starlark_only.sixth_func(), 3)


if __name__ == '__main__':
  unittest.main()
