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

FROM nvidia/cuda-ppc64le:9.0-devel-ubuntu16.04 AS devel

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
    
RUN mkdir -p /var/tmp && wget -q -nc --no-check-certificate -P /var/tmp http://content.mellanox.com/ofed/MLNX_OFED-3.4-1.0.0.0/MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu16.04-ppc64le.tgz && \
    mkdir -p /var/tmp && tar -x -f /var/tmp/MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu16.04-ppc64le.tgz -C /var/tmp -z && \
    dpkg --install /var/tmp/MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu16.04-ppc64le/DEBS/libibverbs1_*_ppc64*.deb /var/tmp/MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu16.04-ppc64le/DEBS/libibverbs-dev_*_ppc64*.deb /var/tmp/MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu16.04-ppc64le/DEBS/ibverbs-utils_*_ppc64*.deb /var/tmp/MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu16.04-ppc64le/DEBS/libibmad_*_ppc64*.deb /var/tmp/MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu16.04-ppc64le/DEBS/libibmad-devel_*_ppc64*.deb /var/tmp/MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu16.04-ppc64le/DEBS/libibumad_*_ppc64*.deb /var/tmp/MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu16.04-ppc64le/DEBS/libibumad-devel_*_ppc64*.deb /var/tmp/MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu16.04-ppc64le/DEBS/libmlx4-1_*_ppc64*.deb /var/tmp/MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu16.04-ppc64le/DEBS/libmlx5-1_*_ppc64*.deb && \
    rm -rf /var/tmp/MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu16.04-ppc64le.tgz /var/tmp/MLNX_OFED_LINUX-3.4-1.0.0.0-ubuntu16.04-ppc64le

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





ADD mpi_bandwidth.c /tmp/mpi_bandwidth.c
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


