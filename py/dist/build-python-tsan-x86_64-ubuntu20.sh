#!/bin/bash

PY_VERSION=3.14
LLVM_VERSION=18.1.8
LLVM_DIST_URL=https://github.com/llvm/llvm-project/releases/download/llvmorg-18.1.8/clang+llvm-18.1.8-x86_64-linux-gnu-ubuntu-18.04.tar.xz

LLVM_DIR=$(basename "${LLVM_DIST_URL}" .tar.xz)
LLVM_MAJOR_VERSION=${LLVM_VERSION%%.*}

CPYTHON_NAME=cpython-${PY_VERSION}.x-tsan-shared-linux-x86_64-llvm-${LLVM_VERSION}
SRC_DIR=$PWD
DST_DIR=/tmp

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

git clone -b ${PY_VERSION} --single-branch https://github.com/python/cpython.git
cd cpython

export LD_LIBRARY_PATH=$SRC_DIR/${LLVM_DIR}/lib/clang/${LLVM_MAJOR_VERSION}/lib/x86_64-unknown-linux-gnu/:$LD_LIBRARY_PATH

# Remove existing directory with binary files
if [ -d "${DST_DIR}/${CPYTHON_NAME}" ]; then
  echo "Remove existing ${DST_DIR}/${CPYTHON_NAME} directory with binary files"
  rm -rf ${DST_DIR}/${CPYTHON_NAME}
fi

./configure \
  --enable-shared \
  --with-thread-sanitizer \
  --disable-gil \
  --with-mimalloc \
  --prefix ${DST_DIR}/${CPYTHON_NAME} \
  CC="$SRC_DIR/$LLVM_DIR/bin/clang" \
  CXX="$SRC_DIR/$LLVM_DIR/bin/clang++" \
  LLVM_PROFDATA="$SRC_DIR/$LLVM_DIR/bin/llvm-profdata" \
  BASECFLAGS="-shared-libsan" \
  LDFLAGS="-shared-libsan -Wl,-rpath,'\$\$ORIGIN/../lib:\$\$ORIGIN/../../../lib'"

make -j64

echo "Installing CPython to ${DST_DIR}/${CPYTHON_NAME}"
make install

echo "Bundling CPython (Ubuntu 20.04 based)..."
cp $SRC_DIR/$LLVM_DIR/lib/clang/${LLVM_MAJOR_VERSION}/lib/x86_64-unknown-linux-gnu/libclang_rt.tsan.so ${DST_DIR}/${CPYTHON_NAME}/lib/

cp /usr/lib/x86_64-linux-gnu/libssl.so.1.1 ${DST_DIR}/${CPYTHON_NAME}/lib/
cp /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1 ${DST_DIR}/${CPYTHON_NAME}/lib/
patchelf --set-rpath '$ORIGIN' ${DST_DIR}/${CPYTHON_NAME}/lib/libssl.so.1.1

cp /usr/lib/x86_64-linux-gnu/libffi.so.7.1.0 ${DST_DIR}/${CPYTHON_NAME}/lib/
cd ${DST_DIR}/${CPYTHON_NAME}/lib/
ln -s libffi.so.7.1.0 libffi.so.7

echo "Creating portable CPython archive..."
cd ${DST_DIR}
tar -czf ${CPYTHON_NAME}.tar.gz ${CPYTHON_NAME}
