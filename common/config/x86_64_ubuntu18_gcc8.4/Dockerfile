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

FROM ubuntu:18.04

RUN apt-get update
RUN apt-get -y install \
    build-essential \
    gcc-8 g++-8 \
    libomp-dev \
    patchelf

RUN rm -rf /usr/include/c++/7.5.0
RUN rm -rf /usr/include/c++/7
RUN rm -rf /usr/include/x86_64-linux-gnu/c++/7.5.0
RUN rm -rf /usr/include/x86_64-linux-gnu/c++/7
RUN rm -rf /usr/lib/gcc/x86_64-linux-gnu/7

# Fix invalid links
WORKDIR /lib64

# Fix /lib64/ld-linux-x86-64.so.2 -> /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
# cd lib64/
# sudo ln -sfn ../lib/x86_64-linux-gnu/ld-2.27.so ./ld-linux-x86-64.so.2
RUN ln -sfn ../lib/x86_64-linux-gnu/ld-2.27.so ./ld-linux-x86-64.so.2

WORKDIR /usr/lib/x86_64-linux-gnu

# /usr/lib/x86_64-linux-gnu/libutil.so -> /lib/x86_64-linux-gnu/libutil.so.1
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libutil.so.1 ./libutil.so
# /usr/lib/x86_64-linux-gnu/libnsl.so -> /lib/x86_64-linux-gnu/libnsl.so.1
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libnsl.so.1 ./libnsl.so
# /usr/lib/x86_64-linux-gnu/libcidn.so -> /lib/x86_64-linux-gnu/libcidn.so.1
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libcidn.so.1 ./libcidn.so
# /usr/lib/x86_64-linux-gnu/libnss_dns.so -> /lib/x86_64-linux-gnu/libnss_dns.so.2
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libnss_dns.so.2 ./libnss_dns.so
# /usr/lib/x86_64-linux-gnu/libnss_hesiod.so -> /lib/x86_64-linux-gnu/libnss_hesiod.so.2
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libnss_hesiod.so.2 ./libnss_hesiod.so
# /usr/lib/x86_64-linux-gnu/librt.so -> /lib/x86_64-linux-gnu/librt.so.1
RUN ln -sfn ../../../lib/x86_64-linux-gnu/librt.so.1 ./librt.so
# /usr/lib/x86_64-linux-gnu/libnss_nisplus.so -> /lib/x86_64-linux-gnu/libnss_nisplus.so.2
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libnss_nisplus.so.2 ./libnss_nisplus.so
# /usr/lib/x86_64-linux-gnu/libcrypt.so -> /lib/x86_64-linux-gnu/libcrypt.so.1
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libcrypt.so.1 ./libcrypt.so
# /usr/lib/x86_64-linux-gnu/libnss_compat.so -> /lib/x86_64-linux-gnu/libnss_compat.so.2
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libnss_compat.so.2 ./libnss_compat.so
# /usr/lib/x86_64-linux-gnu/libBrokenLocale.so -> /lib/x86_64-linux-gnu/libBrokenLocale.so.1
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libBrokenLocale.so.1 ./libBrokenLocale.so
# /usr/lib/x86_64-linux-gnu/libnss_files.so -> /lib/x86_64-linux-gnu/libnss_files.so.2
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libnss_files.so.2 ./libnss_files.so
# /usr/lib/x86_64-linux-gnu/libresolv.so -> /lib/x86_64-linux-gnu/libresolv.so.2
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libresolv.so.2 ./libresolv.so
# /usr/lib/x86_64-linux-gnu/libnss_nis.so -> /lib/x86_64-linux-gnu/libnss_nis.so.2
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libnss_nis.so.2 ./libnss_nis.so
# /usr/lib/x86_64-linux-gnu/libthread_db.so -> /lib/x86_64-linux-gnu/libthread_db.so.1
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libthread_db.so.1 ./libthread_db.so
# /usr/lib/x86_64-linux-gnu/libanl.so -> /lib/x86_64-linux-gnu/libanl.so.1
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libanl.so.1 ./libanl.so
# /usr/lib/x86_64-linux-gnu/libdl.so -> /lib/x86_64-linux-gnu/libdl.so.2
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libdl.so.2 ./libdl.so
# /usr/lib/x86_64-linux-gnu/libmvec.so -> /lib/x86_64-linux-gnu/libmvec.so.1
RUN ln -sfn ../../../lib/x86_64-linux-gnu/libmvec.so.1 ./libmvec.so

# Patch libomp.so.5 to custom soname for import
RUN cp libomp.so.5 libomp-hermetic.so
RUN patchelf --set-soname libomp-hermetic.so libomp-hermetic.so
RUN cp /usr/share/doc/libomp-dev/copyright /usr/lib/x86_64-linux-gnu/libomp-copyright

WORKDIR /root
