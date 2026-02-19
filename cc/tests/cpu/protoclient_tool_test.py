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

import sys
import os
import unittest
from cc.tests.cpu import protoclient

class TestProtoClient(unittest.TestCase):
    def test(self):
        self.assertEqual("Hello, Julius Caesar", protoclient.say_hello("Julius Caesar"))

if __name__ == '__main__':
    print(f"\n--- PYTHON DEBUG INFO ---")
    print(f"Executable: {sys.executable}")
    print(f"Version: {sys.version}")
    print(f"Prefix: {sys.prefix}")
    print(f"PYTHONPATH: {os.environ.get('PYTHONPATH')}")
    print(f"---------------------\n")
    unittest.main()
