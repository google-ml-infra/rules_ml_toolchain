# Create docker image from Dockerfile
# docker build -t sysroot_ubuntu22-x86_64:latest -f ./Dockerfile .

# Run docker image
# docker run -it sysroot_ubuntu22-x86_64

# Copy needed directories from Docker image
# docker cp <DOCKER IMG ID>:/usr .
# docker cp <DOCKER IMG ID>:/lib .
# docker cp <DOCKER IMG ID>:/lib64 .

# Fix invalid links

# Fix ld-linux-x86-64.so.2 -> /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
# cd lib64/
# sudo rm ./ld-linux-x86-64.so.2
# sudo ln -s ../lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 ./ld-linux-x86-64.so.2

# Fix libmvec.so -> /lib/x86_64-linux-gnu/libmvec.so.1
# cd usr/lib/x86_64-linux-gnu/
# rm ./libmvec.so
# sudo ln -s ../../../lib/x86_64-linux-gnu/libmvec.so.1 ./libmvec.so

# Add links
# cd lib/x86_64-linux-gnu/
# sudo ln -s ./libpthread.so.0 ./libpthread.so
# cd usr/lib/x86_64-linux-gnu/
# sudo ln -s ./libdl.so.2 ./libdl.so

FROM ubuntu:22.04

RUN apt-get update
RUN apt-get -y install \
    build-essential \
    gcc-12 g++-12 \
    libomp-dev

RUN rm -rf /usr/include/c++/11
RUN rm -rf /usr/include/x86_64-linux-gnu/c++/11
RUN rm -rf /usr/lib/gcc/x86_64-linux-gnu/11

WORKDIR /root


