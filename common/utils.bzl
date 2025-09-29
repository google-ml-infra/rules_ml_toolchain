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

def extract_tar_xz_file(repository_ctx, file_name, strip_prefix):
    extract_command = "xz -d -T32 {archive}".format(
        archive = file_name,
    )
    exec_result = repository_ctx.execute(
        ["/bin/bash", "-c", extract_command],
    )
    if exec_result.return_code != 0:
        print("Couldn't extract {archive} using xz, falling back to default behavior".format(archive = file_name))
        repository_ctx.extract(
            archive = file_name,
            stripPrefix = strip_prefix,
        )
    else:
        tar_file_name = file_name.replace(".tar.xz", ".tar")
        repository_ctx.extract(
            archive = tar_file_name,
            stripPrefix = strip_prefix,
        )
        repository_ctx.delete(tar_file_name)
