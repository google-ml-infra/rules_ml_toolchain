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

FROM arm64v8/ubuntu:20.04

RUN apt-get update
RUN apt-get -y install \
    build-essential \
    gcc-10 g++-10 \
    libomp-dev \
    patchelf

RUN rm -rf /usr/include/c++/9
RUN rm -rf /usr/include/x86_64-linux-gnu/c++/9
RUN rm -rf /usr/lib/gcc/x86_64-linux-gnu/9

# Replace absolute links by relative in /usr/lib/aarch64-linux-gnu/ directory
WORKDIR /usr/lib/aarch64-linux-gnu

# /usr/lib/aarch64-linux-gnu/libcrypt.so -> /lib/aarch64-linux-gnu/libcrypt.so.1.1.0
RUN ln -sfn ../../../lib/aarch64-linux-gnu/libcrypt.so.1.1.0 ./libcrypt.so
# /usr/lib/aarch64-linux-gnu/libthread_db.so -> /lib/aarch64-linux-gnu/libthread_db.so.1
RUN ln -sfn ../../../lib/aarch64-linux-gnu/libthread_db.so.1 ./libthread_db.so
# /usr/lib/aarch64-linux-gnu/libBrokenLocale.so -> /lib/aarch64-linux-gnu/libBrokenLocale.so.1
RUN ln -sfn ../../../lib/aarch64-linux-gnu/libBrokenLocale.so.1 ./libBrokenLocale.so
# /usr/lib/aarch64-linux-gnu/libnss_nis.so -> /lib/aarch64-linux-gnu/libnss_nis.so.2
RUN ln -sfn ../../../lib/aarch64-linux-gnu/libnss_nis.so.2 ./libnss_nis.so
# /usr/lib/aarch64-linux-gnu/libnsl.so -> /lib/aarch64-linux-gnu/libnsl.so.1
RUN ln -sfn ../../../lib/aarch64-linux-gnu/libnsl.so.1 ./libnsl.so
# /usr/lib/aarch64-linux-gnu/libresolv.so -> /lib/aarch64-linux-gnu/libresolv.so.2
RUN ln -sfn ../../../lib/aarch64-linux-gnu/libresolv.so.2 ./libresolv.so
# /usr/lib/aarch64-linux-gnu/libm.so -> /lib/aarch64-linux-gnu/libm.so.6
RUN ln -sfn ../../../lib/aarch64-linux-gnu/libm.so.6 ./libm.so
# /usr/lib/aarch64-linux-gnu/librt.so -> /lib/aarch64-linux-gnu/librt.so.1
RUN ln -sfn ../../../lib/aarch64-linux-gnu/librt.so.1 ./librt.so
# /usr/lib/aarch64-linux-gnu/libutil.so -> /lib/aarch64-linux-gnu/libutil.so.1
RUN ln -sfn ../../../lib/aarch64-linux-gnu/libutil.so.1 ./libutil.so
# /usr/lib/aarch64-linux-gnu/libpthread.so -> /lib/aarch64-linux-gnu/libpthread.so.0
RUN ln -sfn ../../../lib/aarch64-linux-gnu/libpthread.so.0 ./libpthread.so
# /usr/lib/aarch64-linux-gnu/libnss_hesiod.so -> /lib/aarch64-linux-gnu/libnss_hesiod.so.2
RUN ln -sfn ../../../lib/aarch64-linux-gnu/libnss_hesiod.so.2 ./libnss_hesiod.so
# /usr/lib/aarch64-linux-gnu/libnss_dns.so -> /lib/aarch64-linux-gnu/libnss_dns.so.2
RUN ln -sfn ../../../lib/aarch64-linux-gnu/libnss_dns.so.2 ./libnss_dns.so
# /usr/lib/aarch64-linux-gnu/libnss_compat.so -> /lib/aarch64-linux-gnu/libnss_compat.so.2
RUN ln -sfn ../../../lib/aarch64-linux-gnu/libnss_compat.so.2 ./libnss_compat.so
# /usr/lib/aarch64-linux-gnu/libanl.so -> /lib/aarch64-linux-gnu/libanl.so.1
RUN ln -sfn ../../../lib/aarch64-linux-gnu/libanl.so.1 ./libanl.so
# /usr/lib/aarch64-linux-gnu/libdl.so -> /lib/aarch64-linux-gnu/libdl.so.2
RUN ln -sfn ../../../lib/aarch64-linux-gnu/libdl.so.2 ./libdl.so
# /usr/lib/aarch64-linux-gnu/libnss_files.so -> /lib/aarch64-linux-gnu/libnss_files.so.2
RUN ln -sfn ../../../lib/aarch64-linux-gnu/libnss_files.so.2 ./libnss_files.so
# /usr/lib/aarch64-linux-gnu/libnss_nisplus.so -> /lib/aarch64-linux-gnu/libnss_nisplus.so.2
RUN ln -sfn ../../../lib/aarch64-linux-gnu/libnss_nisplus.so.2 ./libnss_nisplus.so

# Patch libomp.so.5 to custom soname for import
RUN cp libomp.so.5 libomp-hermetic.so
RUN patchelf --set-soname libomp-hermetic.so libomp-hermetic.so
RUN cp /usr/share/doc/libomp-dev/copyright /usr/lib/aarch64-linux-gnu/libomp-copyright

WORKDIR /root
