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


WORKDIR /lib64
# Fix invalid links
RUN ln -sfn ../lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 ./ld-linux-x86-64.so.2

WORKDIR /usr/lib/x86_64-linux-gnu
# Fix invalid links
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libmvec.so.1 ./libmvec.so
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libanl.so.1 ./libanl.so
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libBrokenLocale.so.1 ./libBrokenLocale.so
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libc_malloc_debug.so.0 ./libc_malloc_debug.so
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libcrypt.so.1 ./libcrypt.so
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libnss_compat.so.2 ./libnss_compat.so
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libnss_hesiod.so.2 ./libnss_hesiod.so
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libresolv.so.2 ./libresolv.so
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libthread_db.so.1 ./libthread_db.so
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libtirpc.so.3.0.0 ./libtirpc.so
# Add links
RUN ln -s ./libdl.so.2 ./libdl.so

WORKDIR /lib/x86_64-linux-gnu
# Add links
RUN ln -s ./libpthread.so.0 ./libpthread.so

# Patch libomp.so.5 to custom soname for import
RUN cp libomp.so.5 libomp-hermetic.so
RUN patchelf --set-soname libomp-hermetic.so libomp-hermetic.so
RUN cp /usr/share/doc/libomp-dev/copyright /usr/lib/x86_64-linux-gnu/libomp-copyright

WORKDIR /root


