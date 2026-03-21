import unittest
from pybind import pybind as regular
from pybind import pybind_copy as regular_copy
from pybind import pybind_with_starlark_only as regular_with_starlark_only


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
