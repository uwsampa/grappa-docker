#!/bin/bash

apt-get update
apt-get install -y \
  libboost1.55-all-dev \
  wget \
  make \
  cmake \
  ninja-build \
  git \
  openssh-server \
  bash-completion \
  man \
  openssl

# build recent version of Ruby
wget http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.2.tar.gz && \
  tar xzf ruby-2.1.2.tar.gz && \
  cd ruby-2.1.2 && \
  ./configure && \
  make && \
  make install

cd /

# build OpenMPI
wget http://www.open-mpi.org/software/ompi/v1.8/downloads/openmpi-1.8.1.tar.gz && \
  tar xzf openmpi-1.8.1.tar.gz && \
  cd openmpi-1.8.1 && \
  CC=$(which gcc) CXX=$(which g++) ./configure --enable-contrib-no-build=vt --prefix=/usr && \
  make && \
  make install

cd /

# clean up
rm -rf openmpi-1.8.1* ruby-2.1.2*

# build grappa-third-party libs
git clone https://github.com/uwsampa/grappa.git /grappa

cd grappa
./configure --cc=$(which gcc) --gen=Ninja \
              --third-party=/grappa-third-party \
              --shmmax=$((1<<30)) && \
  cd build/Ninja+Release && \
  ninja

cd /
