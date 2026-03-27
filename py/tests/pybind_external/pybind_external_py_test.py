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

import os
import unittest
from py.tests.pybind import pybind as regular
from py.tests.pybind import pybind_copy as regular_copy
import py.tests.pybind
import py.tests.pybind_copy
from py.tests.pybind import _EXTRA_SYMBOL as REGULAR_EXTRA_SYMBOL
from py.tests.pybind_copy import _EXTRA_SYMBOL as REGULAR_COPY_EXTRA_SYMBOL
from py.tests.pybind.sub import second_func as sub_second_func
import py.tests.pybind.sub
from py.tests.pybind.sub._sub_private import *
from py.tests.pybind.sub._sub_private import _sub_private_private_func
from py.tests.pybind.sub_pybind.relative_import_lib import call_nested_pyind_func
from py.tests.pybind.sub_pybind.relative_import_lib import sub_sub_private_func

class PybindTest(unittest.TestCase):
  def _read_file(self, filename, mode="r"):
    with open(filename, mode) as file:
      file_content = file.read()
    return file_content

  def test_pybind_first(self):
    print("1: regular.first_func")
    self.assertEqual(regular.first_func(1), 2)
    print("2: py.tests.pybind.second_func")
    self.assertEqual(py.tests.pybind.second_func(1), 2)
    print("3: regular.third_func")
    self.assertEqual(regular.third_func(1), 1)
    print("4: py.tests.pybind_copy.first_func")
    self.assertEqual(py.tests.pybind_copy.first_func(1), 4)
    print("5: regular_copy.second_func")
    self.assertEqual(regular_copy.second_func(1), 4)
    print("6: regular_copy.third_func")
    self.assertEqual(regular_copy.third_func(1), 1)
    print("7: regular.second_global_func")
    self.assertEqual(regular.second_global_func(), 2)
    print("8: regular_copy.second_global_func")
    self.assertEqual(regular.second_global_func(), 2)
    print("9: REGULAR_EXTRA_SYMBOL")
    self.assertEqual(REGULAR_EXTRA_SYMBOL, 123)
    print("10: REGULAR_COPY_EXTRA_SYMBOL")
    self.assertEqual(REGULAR_COPY_EXTRA_SYMBOL, 123)

    print("11: binary resource size")
    if "nt" in os.name:
      self.assertTrue(self._read_file("data/data_binary.exe", "rb"))
    else:
      self.assertTrue(self._read_file("data/data_binary", "rb"))
    print("12: data/static_resource")
    self.assertEqual(self._read_file("data/static_resource.txt"),
                     "A static resource file under data dir")
    print("13: py/tests/static_resource.txt")
    self.assertEqual(self._read_file("py/tests/static_resource.txt"),
                     "A static resource file under pybind dir")

    print("14: Submodules")
    self.assertEqual(sub_second_func(1), 5)
    self.assertEqual(py.tests.pybind.sub.second_func(1), 6)
    self.assertEqual(py.tests.pybind.sub._sub_private.sub_sub_func(3), 6)
    self.assertEqual(_sub_private_private_func(5), 10)

    print("15: Nested pybinds and relative imports")
    self.assertEqual(call_nested_pyind_func(6), 3)
    self.assertEqual(sub_sub_private_func(5), 10)

if __name__ == '__main__':
  unittest.main()
