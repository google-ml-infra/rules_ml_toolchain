#!/bin/bash

# Copyright 2026 Google LLC
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

# Automated script for compiling CPython with AddressSanitizer (ASan) instrumentation

PY_VERSION=3.13
PY_REPO_TAG=v${PY_VERSION}.12 # Find https://github.com/python/cpython latest stable tag
LLVM_VERSION=18.1.8
LLVM_DIST_URL=https://github.com/llvm/llvm-project/releases/download/llvmorg-18.1.8/clang+llvm-18.1.8-x86_64-linux-gnu-ubuntu-18.04.tar.xz

LLVM_DIR=$(basename "${LLVM_DIST_URL}" .tar.xz)
LLVM_MAJOR_VERSION=${LLVM_VERSION%%.*}

CPYTHON_NAME=cpython-${PY_VERSION}.x-asan-shared-linux-x86_64-llvm-${LLVM_VERSION}
SRC_DIR=$PWD
DST_DIR=/tmp

export ASAN_OPTIONS="detect_leaks=0:verify_asan_link_order=0"

echo "Install build essentials..."
apt install -y build-essential gdb lcov pkg-config \
  libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
  libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev \
  lzma lzma-dev tk-dev uuid-dev zlib1g-dev libmpdec-dev git wget xxd libtinfo5 \
  patchelf

if [ ! -d "$LLVM_DIR" ]; then
  echo "Downloading and extracting LLVM $LLVM_VERSION..."
  wget ${LLVM_DIST_URL}
  tar -xf $(basename "${LLVM_DIST_URL}")
fi

echo "Building CPython sources..."
if [ -d "cpython" ]; then
  echo "Remove previously cloned cpython directory..."
  rm -rf cpython
fi

git clone -b ${PY_REPO_TAG} --depth 1 https://github.com/python/cpython.git
cd cpython

export LD_LIBRARY_PATH=$SRC_DIR/${LLVM_DIR}/lib/clang/${LLVM_MAJOR_VERSION}/lib/x86_64-unknown-linux-gnu/:$LD_LIBRARY_PATH

# Remove existing directory with binary files
if [ -d "${DST_DIR}/${CPYTHON_NAME}" ]; then
  echo "Remove existing ${DST_DIR}/${CPYTHON_NAME} directory with binary files"
  rm -rf ${DST_DIR}/${CPYTHON_NAME}
fi

./configure \
  --enable-shared \
  --with-address-sanitizer \
  --without-pymalloc \
  --prefix ${DST_DIR}/${CPYTHON_NAME} \
  CC="$SRC_DIR/$LLVM_DIR/bin/clang" \
  CXX="$SRC_DIR/$LLVM_DIR/bin/clang++" \
  LLVM_PROFDATA="$SRC_DIR/$LLVM_DIR/bin/llvm-profdata" \
  BASECFLAGS="-shared-libasan" \
  LDFLAGS="-shared-libasan -Wl,-rpath,'\$\$ORIGIN/../lib:\$\$ORIGIN/../../../lib'"
  #--disable-ipv6 \ # Disable due to error portpicker.NoFreePortFoundError
  #--without-pydebug \
  #--enable-optimizations \

make -j64

echo "Installing CPython to ${DST_DIR}/${CPYTHON_NAME}"
make install

echo "Bundling CPython (Ubuntu 20.04 based)..."
cp $SRC_DIR/$LLVM_DIR/lib/clang/${LLVM_MAJOR_VERSION}/lib/x86_64-unknown-linux-gnu/libclang_rt.asan.so ${DST_DIR}/${CPYTHON_NAME}/lib/

cp /usr/lib/x86_64-linux-gnu/libssl.so.1.1 ${DST_DIR}/${CPYTHON_NAME}/lib/
cp /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1 ${DST_DIR}/${CPYTHON_NAME}/lib/
patchelf --set-rpath '$ORIGIN' ${DST_DIR}/${CPYTHON_NAME}/lib/libssl.so.1.1

cp /usr/lib/x86_64-linux-gnu/libffi.so.7.1.0 ${DST_DIR}/${CPYTHON_NAME}/lib/
cd ${DST_DIR}/${CPYTHON_NAME}/lib/
ln -s libffi.so.7.1.0 libffi.so.7

echo "Creating portable CPython archive..."
cd ${DST_DIR}
tar -czf ${CPYTHON_NAME}.tar.gz ${CPYTHON_NAME}
