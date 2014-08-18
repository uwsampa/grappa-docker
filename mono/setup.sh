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
  man

# build recent version of Ruby
wget http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.2.tar.gz && \
  tar xzf ruby-2.1.2.tar.gz && \
  cd ruby-2.1.2 && \
  ./configure && \
  make && \
  make install

# build OpenMPI
wget http://www.open-mpi.org/software/ompi/v1.8/downloads/openmpi-1.8.1.tar.gz && \
  tar xzf openmpi-1.8.1.tar.gz && \
  cd openmpi-1.8.1 && \
  CC=$(which gcc) CXX=$(which g++) ./configure --enable-contrib-no-build=vt --prefix=/usr && \
  make && \
  make install

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

# have to make sure we re-set shmmax before running any Grappa programs
echo "sudo sysctl -w kernel.shmmax=$((1<<30)) >/dev/null 2>/dev/null" >> /etc/profile

# set prompt colors because I'm a bit vain about that
echo "export PS1='\[\e[0;34m\]docker \[\e[m\]\[\e[0;32m\]\w\[\e[m\] \[\e[0;33m\]\$ \[\e[m\]'" >> /etc/profile

# enable tab completion
echo "source /etc/bash_completion" >> /etc/profile
