FROM ubuntu:xenial
LABEL Name=ubuntu_docker Version=0.0.1

# Update apps on the base image
RUN apt -y update && apt install -y \
    build-essential \
    gawk \
    xutils-dev \
    csh \
    tcsh \
    wget \
    git
RUN ln -sf /lib/x86_64-linux-gnu/libz.so.1 /lib/x86_64-linux-gnu/libz.so && ln -s /usr/bin/awk /bin/awk

# Install Older gcc/g++
RUN apt-get -y update && apt-get -y install gcc-4.8 g++-4.8

# Install Newer Cmake
WORKDIR /usr/src/cmake
RUN apt -y remove --purge --auto-remove cmake && version=3.16 && build=2 && wget https://cmake.org/files/v$version/cmake-$version.$build-Linux-x86_64.sh
RUN mkdir /opt/cmake && version=3.16 && build=2 && printf 'y\nn\n' | sh cmake-$version.$build-Linux-x86_64.sh --prefix=/opt/cmake --skip-license && ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake

# Copy Orchestra.tgz file
WORKDIR /usr/src/orchestra
COPY ./orchestra-sdk-1.8-1.x86_64.tgz ./
RUN tar -xzf orchestra-sdk-1.8-1.x86_64.tgz && rm -f *.tgz

# Install Orchestra Examples
RUN mkdir build && mkdir source && cp -r orchestra-sdk-1.8-1/Examples/* ./source
RUN cd build && CC=gcc-4.8 CXX=g++-4.8 cmake -D OX_INSTALL_DIRECTORY=/usr/src/orchestra/orchestra-sdk-1.8-1/ -G 'Unix Makefiles' ../source && make
