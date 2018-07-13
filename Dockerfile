# 
# HPC Base image
# 
# Contents:
#   CUDA version 9.0
#   FFTW version 3.3.7
#   GNU compilers (upstream)
#   HDF5 version 1.10.1
#   Mellanox OFED version 3.4-1.0.0.0
#   OpenMPI version 3.0.0
#   Python 2 and 3 (upstream)
# 

FROM nvidia/cuda:9.0-devel-ubuntu16.04 AS devel

# Python
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        python \
        python3 && \
    rm -rf /var/lib/apt/lists/*

# GNU compiler
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        gcc \
        g++ \
        gfortran && \
    rm -rf /var/lib/apt/lists/*

# Mellanox OFED version 3.4-1.0.0.0
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates  \
        libnl-3-200 \
        libnl-route-3-200 \
        libnuma1 \
        wget && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp http://content.mellanox.com/ofed/MLNX_OFED-3.4-1.0.0.0/MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu16.04-x86_64.tgz && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu16.04-x86_64.tgz -C /var/tmp -z && \
    dpkg --install /var/tmp/MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu16.04-x86_64/DEBS/libibverbs1_*_amd64.deb /var/tmp/MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu16.04-x86_64/DEBS/libibverbs-dev_*_amd64.deb /var/tmp/MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu16.04-x86_64/DEBS/ibverbs-utils_*_amd64.deb /var/tmp/MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu16.04-x86_64/DEBS/libibmad_*_amd64.deb /var/tmp/MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu16.04-x86_64/DEBS/libibmad-devel_*_amd64.deb /var/tmp/MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu16.04-x86_64/DEBS/libibumad_*_amd64.deb /var/tmp/MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu16.04-x86_64/DEBS/libibumad-devel_*_amd64.deb /var/tmp/MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu16.04-x86_64/DEBS/libmlx4-1_*_amd64.deb /var/tmp/MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu16.04-x86_64/DEBS/libmlx5-1_*_amd64.deb && \
    rm -rf /var/tmp/MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu16.04-x86_64.tgz /var/tmp/MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu16.04-x86_64

# OpenMPI version 3.0.0
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        bzip2 \
        file \
        hwloc \
        make \
        openssh-client \
        perl \
        tar \
        wget && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp https://www.open-mpi.org/software/ompi/v3.0/downloads/openmpi-3.0.0.tar.bz2 && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/openmpi-3.0.0.tar.bz2 -C /var/tmp -j && \
    cd /var/tmp/openmpi-3.0.0 &&  CC=gcc CXX=g++ F77=gfortran F90=gfortran FC=gfortran ./configure --prefix=/usr/local/openmpi --disable-getpwuid --enable-orterun-prefix-by-default --with-cuda=/usr/local/cuda --with-verbs && \
    make -j4 && \
    make -j4 install && \
    rm -rf /var/tmp/openmpi-3.0.0.tar.bz2 /var/tmp/openmpi-3.0.0
ENV LD_LIBRARY_PATH=/usr/local/openmpi/lib:$LD_LIBRARY_PATH \
    PATH=/usr/local/openmpi/bin:$PATH

# FFTW version 3.3.7
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        file \
        make \
        wget && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp ftp://ftp.fftw.org/pub/fftw/fftw-3.3.7.tar.gz && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/fftw-3.3.7.tar.gz -C /var/tmp -z && \
    cd /var/tmp/fftw-3.3.7 &&  CC=gcc CXX=g++ F77=gfortran F90=gfortran FC=gfortran ./configure --prefix=/usr/local/fftw --enable-shared --enable-openmp --enable-threads --enable-sse2 && \
    make -j4 && \
    make -j4 install && \
    rm -rf /var/tmp/fftw-3.3.7.tar.gz /var/tmp/fftw-3.3.7
ENV LD_LIBRARY_PATH=/usr/local/fftw/lib:$LD_LIBRARY_PATH

# HDF5 version 1.10.1
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        file \
        make \
        wget \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp http://www.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.1/src/hdf5-1.10.1.tar.bz2 && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/hdf5-1.10.1.tar.bz2 -C /var/tmp -j && \
    cd /var/tmp/hdf5-1.10.1 &&  CC=gcc CXX=g++ F77=gfortran F90=gfortran FC=gfortran ./configure --prefix=/usr/local/hdf5 --enable-cxx --enable-fortran && \
    make -j4 && \
    make -j4 install && \
    rm -rf /var/tmp/hdf5-1.10.1.tar.bz2 /var/tmp/hdf5-1.10.1
ENV HDF5_DIR=/usr/local/hdf5 \
    LD_LIBRARY_PATH=/usr/local/hdf5/lib:$LD_LIBRARY_PATH \
    PATH=/usr/local/hdf5/bin:$PATH

COPY mpi_bandwidth.c /tmp/mpi_bandwidth.c
RUN mkdir -p /workspace && \
    mpicc -o /workspace/mpi_bandwidth /tmp/mpi_bandwidth.c

#RUN apt-get update && apt-get install -y --no-install-recommends \
#           libelf1 libelf-dev \
#            libffi6 libffi-dev \
#            build-essential \
#            git \
#            cmake \

RUN curl -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/nimbix/image-common/master/install-nimbix.sh | bash

ADD url.txt /etc/NAE/url.txt
ADD help.html /etc/NAE/help.html
ADD AppDef.json /etc/NAE/AppDef.json
RUN wget --post-file=/etc/NAE/AppDef.json --no-verbose https://api.jarvice.com/jarvice/validate -O -

# Expose port 22 for local JARVICE emulation in docker
#EXPOSE 22


