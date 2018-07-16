# 
# HPC Base image
# 
# Contents:
#   CUDA version 9.2
#   OpenMPI version 3.0.0
#   Python 2 and 3 (upstream)
#   gnu compilers

FROM nvidia/cuda-ppc64le:9.2-devel-ubuntu16.04 AS devel

# Python + gnu compiler
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        curl \
        python3 \ 
        gcc \
        g++ \
        gfortran \
        libnuma1 \
        pciutils
        
RUN curl -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/nimbix/image-common/master/install-nimbix.sh | bash

# OpenMPI version 3.0.0
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        bzip2 \
        file \
        hwloc \
        make \
        perl \
        tar \
        wget \
        perftest \
        cuda-samples-9-2
     
ENV OPENMPI_VERS=openmpi-3.1.1.tar.bz2     
RUN mkdir -p /var/tmp && \
    wget -q -nc --no-check-certificate -P /var/tmp https://www.open-mpi.org/software/ompi/v3.0/downloads/openmpi-$OPENMPI_VERS.tar.bz2 && \
    tar -x -f /var/tmp/openmpi-$OPENMPI_VERS.tar.bz2 -C /var/tmp -j && \
    cd /var/tmp/openmpi-$OPENMPI_VERS &&  \
    CC=gcc CXX=g++ F77=gfortran F90=gfortran FC=gfortran ./configure --prefix=/usr/local/openmpi --disable-getpwuid --enable-orterun-prefix-by-default --with-cuda=/usr/local/cuda --with-verbs && \
    make -j16 && \
    make -j16 install && \
    rm -rf /var/tmp/openmpi-$OPENMPI_VERS.tar.bz2 /var/tmp/openmpi-$OPENMPI_VERS

ENV LD_LIBRARY_PATH=/usr/local/openmpi/lib:$LD_LIBRARY_PATH \
    PATH=/usr/local/openmpi/bin:$PATH

RUN mkdir -p /workspace
ADD mpi_bw.c /workspace
RUN mpicc -o /workspace/mpi_bw /tmp/mpi_bw.c
    
RUN cd /usr/local/cuda/samples && make -j16

ADD url.txt /etc/NAE/url.txt
ADD help.html /etc/NAE/help.html
ADD AppDef.json /etc/NAE/AppDef.json
RUN wget --post-file=/etc/NAE/AppDef.json --no-verbose https://api.jarvice.com/jarvice/validate -O -

# Expose port 22 for local JARVICE emulation in docker
#EXPOSE 22


