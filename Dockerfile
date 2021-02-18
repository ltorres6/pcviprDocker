FROM ubuntu:bionic AS builder
LABEL Name=ubuntu_docker Version=0.0.1
ENV SDKTOP /usr/src/orchestra-sdk-1.10-1/
ENV VDS_GRADIENT_PATH /usr/local/PsdGradFiles/
ENV OX_INSTALL_DIRECTORY=/usr/src/orchestra-sdk-1.10-1/
ENV MKL_ROOT=/opt/intel/mkl/
ENV MKLROOT=/opt/intel/mkl/
ENV MKL_INCLUDE=/opt/intel/mkl/include/
ENV MKL_LIBRARY=/opt/intel/mkl/lib/intel64
ARG USERNAME=change_to_match_host
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/bash \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Update apps on the base image
RUN apt -y update && apt install -y \
    build-essential \
    gawk \
    xutils-dev \
    csh \
    tcsh \
    wget \
    git \
    apt-utils
RUN ln -sf /lib/x86_64-linux-gnu/libz.so.1 /lib/x86_64-linux-gnu/libz.so && ln -s /usr/bin/awk /bin/awk

# Install Older gcc/g++
RUN apt -y update && apt -y install gcc-4.8 g++-4.8 apt-transport-https ca-certificates locales libgomp1 libgfortran3 software-properties-common
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8
RUN apt clean

# Install Newer Cmake
WORKDIR /usr/src/cmake
RUN apt -y remove --purge --auto-remove cmake && version=3.16 && build=2 && wget --no-check-certificate https://cmake.org/files/v$version/cmake-$version.$build-Linux-x86_64.sh
RUN mkdir /opt/cmake && version=3.16 && build=2 && printf 'y\nn\n' | sh cmake-$version.$build-Linux-x86_64.sh --prefix=/opt/cmake --skip-license && ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake

# Copy Orchestra.tgz file and untar it
ADD orchestra-sdk-1.10-1.tgz /usr/src/

WORKDIR /usr/src/
# Install Orchestra Examples
RUN mkdir build && mkdir source && cp -r orchestra-sdk-1.10-1/Examples/* ./source
RUN cd build && CC=gcc-4.8 CXX=g++-4.8 cmake -DOX_INSTALL_DIRECTORY=/usr/src/orchestra-sdk-1.10-1/ -G 'Unix Makefiles' ../source && make -j 4 && make install

# copy some libraries for pcvipr
RUN cp -r $SDKTOP/3p/include/blitz/* /usr/local/include/ \
    && cp -r $SDKTOP/3p/lib/libblitz.la /usr/local/lib/ \
    && cp -r $SDKTOP/3p/lib/libblitz.a /usr/local/lib/ \
    && cp -r $SDKTOP/3p/lib/pkgconfig/blitz.pc /usr/local/lib/ \
    && cp -r $SDKTOP/3p/include/H5* /usr/local/include/ \
    && cp -r $SDKTOP/3p/include/hdf5.h /usr/local/include/ \
    && cp -r $SDKTOP/3p/include/ph5diff.h /usr/local/include/ \
    && cp -r $SDKTOP/3p/lib/libh* /usr/local/lib/

# Install MKL
WORKDIR ${HOME}/local_setup/
RUN wget --no-check-certificate https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB
RUN apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB && echo 'deb https://apt.repos.intel.com/mkl all main' > /etc/apt/sources.list.d/intel-mkl.list
RUN apt-get update && apt-get install -y intel-mkl-64bit-2019.4-070 2019.4-070
RUN echo "/opt/intel/lib/intel64" > /etc/ld.so.conf.d/mkl.conf && echo "/opt/intel/lib/intel64" > /etc/ld.so.conf.d/mkl.conf && ldconfig

# # Install FFTW
RUN apt install libfftw3-dev libfftw3-3 -y

# Install ARMADILLO
RUN wget --no-check-certificate https://downloads.sourceforge.net/project/arma/armadillo-9.900.1.tar.xz
RUN tar xvf armadillo-9.900.1.tar.xz
RUN cd armadillo-9.900.1 && sed -i '/include(ARMA_FindARPACK)/d' CMakeLists.txt \
    && CC=gcc-4.8 CXX=g++-4.8 FC=gfortran-4.8 ./configure -DCMAKE_INSTALL_PREFIX=/usr/local/ -DBUILD_SHARED_LIBS=no && make -j 4 \
    && make install && cd ../

# Install VORO
RUN apt install voro++ voro++-dev -y

# Install ge_data_tools
ADD ge_data_tools.tgz ${HOME}/local_setup/
RUN cd ge_data_tools && mkdir build && cd build && CC=gcc-4.8 CXX=g++-4.8 FC=gfortran-4.8 cmake ../ -DCMAKE_INSTALL_PREFIX=/usr/local/ && make -j 12 && make install

# Install mri_recon
ADD mri_recon.tgz ${HOME}/local_setup/
RUN cd mri_recon && mkdir build && cd build && CC=gcc-4.8 CXX=g++-4.8 FC=gfortran-4.8 cmake ../ -DENABLE_ORCHESTRA="yes" -DCMAKE_INSTALL_PREFIX=/usr/local/ && make -j 12 && make install

# Install pcvipr_wrapper
ADD pcvipr_wrapper.tgz ${HOME}/local_setup/
RUN cd pcvipr_wrapper && mkdir build && cd build && CC=gcc-4.8 CXX=g++-4.8 FC=gfortran-4.8 cmake ../ -DCMAKE_INSTALL_PREFIX=/usr/local/ && make -j 12 && make install

# Remove Source Code
RUN rm -rf /local_setup/

# Add vds_gradients
ADD PsdGradFiles.tar /usr/local/

# Use multi-stage build to clear source code history
FROM ubuntu:bionic
ENV SDKTOP /usr/src/orchestra-sdk-1.10-1/
ENV VDS_GRADIENT_PATH /usr/local/PsdGradFiles/
ENV OX_INSTALL_DIRECTORY=/usr/src/orchestra-sdk-1.10-1/
ENV MKL_ROOT=/opt/intel/mkl
ENV MKLROOT=/opt/intel/mkl
ENV MKL_INCLUDE=/opt/intel/mkl/include
ENV MKL_LIBRARY=/opt/intel/mkl/lib/intel64
ARG USERNAME=change_to_match_host
ARG USER_UID=1000
ARG USER_GID=$USER_UID
COPY --from=builder / /

USER $USERNAME
WORKDIR /home/$USERNAME
