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

from argparse import ArgumentParser
from cc.tests.cpu import protogen


def save_proto(file_name):
    f = open(file_name, "w")
    f.write(protogen.get_proto())


parser = ArgumentParser()
parser.add_argument("-f", "--file", dest="filename",
                    help="write report to FILE", metavar="FILE")

args = parser.parse_args()

if str.isspace(args.filename):
    print("Put correct filename. For example: -f './my.proto'")
else:
    save_proto(args.filename)

# Write proto to file
# Command line arguments:
#   file_name - name of file for *.proto
# print(libpybind.first_func(3, 2))
