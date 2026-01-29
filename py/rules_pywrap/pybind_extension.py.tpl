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

from sys import modules
from types import ModuleType


def __update_globals(new_import_path, pywrap_m):
  all_names = pywrap_m.__all__ if hasattr(pywrap_m, '__all__') else dir(
      pywrap_m)
  modules[new_import_path] = pywrap_m
  for name in all_names:
    sub_pywrap = getattr(pywrap_m, name)
    if isinstance(sub_pywrap, ModuleType):
      sub_name = sub_pywrap.__name__[len(pywrap_m.__name__):]
      __update_globals(new_import_path + sub_name, sub_pywrap)


def __try_import():
  imports_paths = []  # template_val
  exceptions = []
  last_exception = None
  for import_path in imports_paths:
    try:
      pywrap_m = __import__(import_path, fromlist=["*"])
      __update_globals(__name__, pywrap_m)
      return
    except ImportError as e:
      exceptions.append(str(e))
      last_exception = e
      pass

  raise RuntimeError(f"""
Could not import original test/binary location, import paths tried: {imports_paths}. 
Previous exceptions: {exceptions}""", last_exception)


__try_import()
