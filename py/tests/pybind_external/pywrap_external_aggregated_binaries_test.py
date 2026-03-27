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

import platform
import unittest
import json
import argparse

def parse_args() -> argparse.Namespace:
  parser = argparse.ArgumentParser()
  parser.add_argument("--wheel-locations", required=True)
  return parser.parse_args()

class PywrapExternalAggregatedBinariesTest(unittest.TestCase):
  def test_pywrap_binaries(self):
    args = parse_args()
    with open(args.wheel_locations) as f:
      wheel_locations = json.load(f)

    relative_wheel_locations = [
        ("/py/tests/pywrap_external/pybind.{pyextension}",
         "/py/tests/pybind/pybind.{pyextension}"),
        ("/py/tests/pybind/pybind.py", ""),
        ("/py/tests/pywrap_external/pybind_copy.{pyextension}",
         "/py/tests/pybind/pybind_copy.{pyextension}"),
        ("/py/tests/pybind/pybind_copy.py", ""),
        ("/py/tests/pywrap_external/pybind_cc_only.{pyextension}", ""),
        ("/py/tests/pywrap_external/pybind_with_starlark_only.{pyextension}", ""),
        ("/py/tests/pybind/pybind_with_starlark_only.py", ""),
        ("/py/tests/pywrap_external/{lib}pywrap_external_aggregated_common.{extension}",
         "/py/tests/pywrap_external/{lib}pywrap_external_aggregated_common.{extension}"),
        (
            "/py/tests/pywrap_external/{lib}pywrap_external_aggregated__starlark_only_common.{extension}",
            ""),
        ('/py/tests/pybind/sub_pybind/nested_pybind.py', ''),
        ('/py/tests/pywrap_external/nested_pybind.{pyextension}',
         '/py/tests/pybind/sub_pybind/nested_pybind.{pyextension}'),
    ]

    pyextension = "so"
    extension = "so"
    lib_prefix = "lib"
    system = platform.system()
    if "Windows" in system:
      relative_wheel_locations.extend([
          ("/py/tests/pywrap_external/framework.2.dll", "/py/tests/framework.2.dll"),
          ("/py/tests/pywrap_external/framework.2.dll.if.lib",
           "/py/tests/pybind/framework.2.dll.if.lib"),
          (
              "/py/tests/pywrap_external/pywrap_external_aggregated__starlark_only_common.dll.if.lib",
              ""),
          ("/py/tests/pywrap_external/pywrap_external_aggregated_common.dll.if.lib",
           "/py/tests/pywrap_external/pywrap_external_aggregated_common.dll.if.lib"),
      ])
      pyextension = "pyd"
      extension = "dll"
      lib_prefix = ""
    elif "Darwin" in system:
      extension = "dylib"
      relative_wheel_locations.extend([
          ("/py/tests/pywrap_external/libframework.2.dylib",
           "/py/tests/pybind/libframework.2.dylib"),
      ])
    else:
      relative_wheel_locations.extend([
          ("/py/tests/pywrap_external/libframework.so.2", "/py/tests/pybind/libframework.so.2"),
      ])

    expected_relative_wheel_locations = {}
    for k, v in relative_wheel_locations:
      new_k = k.format(pyextension=pyextension, extension=extension,
                       lib=lib_prefix)
      new_v = v.format(pyextension=pyextension, extension=extension,
                       lib=lib_prefix)
      expected_relative_wheel_locations[new_k] = new_v

    for rel_src, rel_dest in expected_relative_wheel_locations.items():
      matched_srcs = None
      for src, dest in wheel_locations.items():
        if not src.endswith(rel_src):
          continue
        self.assertEqual(dest[-len(rel_dest):], rel_dest)
        del wheel_locations[src]
        matched_srcs = src
        break
      self.assertTrue(matched_srcs, msg="Could not find " + rel_src)

    self.assertEqual(wheel_locations, {})

if __name__ == "__main__":
  PywrapExternalAggregatedBinariesTest().test_pywrap_binaries()
