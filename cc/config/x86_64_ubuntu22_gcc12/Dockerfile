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

FROM ubuntu:22.04

RUN apt-get update
RUN apt-get -y install \
    build-essential \
    gcc-12 g++-12 \
    libomp-dev \
    patchelf

RUN rm -rf /usr/include/c++/11
RUN rm -rf /usr/include/x86_64-linux-gnu/c++/11
RUN rm -rf /usr/lib/gcc/x86_64-linux-gnu/11

# Fix invalid links
WORKDIR /lib64

# Fix /lib64/ld-linux-x86-64.so.2 -> /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
RUN ln -sfn ../lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 ./ld-linux-x86-64.so.2

WORKDIR /usr/lib/x86_64-linux-gnu
# Fix /lib64/libmvec.so -> /lib/x86_64-linux-gnu/libmvec.so.1
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libmvec.so.1 ./libmvec.so
# Add /usr/lib/x86_64-linux-gnu/libdl.so -> /usr/lib/x86_64-linux-gnu/libdl.so.2
RUN ln -s ./libdl.so.2 ./libdl.so

WORKDIR /lib/x86_64-linux-gnu
# Add /lib/x86_64-linux-gnu/libpthread.so -> /lib/x86_64-linux-gnu/libpthread.so.0
RUN ln -s ./libpthread.so.0 ./libpthread.so

# Patch libomp.so.5 to custom soname for import
RUN cp libomp.so.5 libomp-hermetic.so
RUN patchelf --set-soname libomp-hermetic.so libomp-hermetic.so

WORKDIR /root


