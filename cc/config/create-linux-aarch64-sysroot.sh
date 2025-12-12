#!/bin/bash

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

if [ ! -f "./Dockerfile" ]; then
    echo "Error: The required Dockerfile was not found. Please create a symbolic link to this script under a specific sysroot directory, for example, \"x86_64_ubuntu22_gcc12\" or \"aarch64_ubuntu20_gcc10\" and then run it." >&2
    exit 1
fi

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <version>"
fi

SYSROOT="$(basename "$(pwd)")"
CONTAINER=$(echo "$SYSROOT" | sed -E 's/.*ubuntu([0-9]+).*/u\1sysroot/')

echo "Please enter sysroot version (default: 0.1.0):"
read VERSION
if [ -z "$VERSION" ]; then
    VERSION="0.1.0"
fi

ARCH_NAME=$SYSROOT-$VERSION

# Remove old files and image
rm -rf /tmp/$ARCH_NAME
docker rm -f $CONTAINER
docker rmi -f $ARCH_NAME:latest

# Create docker image from Dockerfile
echo -e "\nBuilding docker image $ARCH_NAME:latest"
docker build -t $ARCH_NAME:latest .

# Run docker image
echo -e "\nRunning docker image $ARCH_NAME:latest, container name $CONTAINER"
docker run -d --name $CONTAINER $ARCH_NAME:latest bash -c "sleep 20"

echo -e "\nCopying files from docker container..."
mkdir /tmp/$ARCH_NAME

# Copy needed directories from Docker image
docker cp $CONTAINER:/lib /tmp/$ARCH_NAME/
docker cp $CONTAINER:/usr /tmp/$ARCH_NAME/

# Remove not used directories
rm -rf /tmp/$ARCH_NAME/lib/cpp
rm -rf /tmp/$ARCH_NAME/usr/bin
rm -rf /tmp/$ARCH_NAME/usr/games
rm -rf /tmp/$ARCH_NAME/usr/sbin
rm -rf /tmp/$ARCH_NAME/usr/src

# Remove share directory but restore copyright files
rm -rf /tmp/$ARCH_NAME/usr/share
mkdir /tmp/$ARCH_NAME/usr/share
docker cp $CONTAINER:/usr/share/common-licenses /tmp/$ARCH_NAME/usr/share/
docker cp $CONTAINER:/usr/share/doc /tmp/$ARCH_NAME/usr/share/

echo -e "\nCreating /tmp/$ARCH_NAME.tar.xz archive..."
XZ_OPT="-T8"
tar -cJf /tmp/$ARCH_NAME.tar.xz -C /tmp/ $ARCH_NAME