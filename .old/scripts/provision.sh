#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y \
        build-essential \
        curl \
        git \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        python-dev \
        python-numpy \
        python-pip \
        software-properties-common \
        swig \
        zip \
        zlib1g-dev \
        wget \
        default-jdk default-jre 

sudo apt-get clean all

mkdir -p /tmp/downloads
cd /tmp/downloads
wget https://github.com/bazelbuild/bazel/releases/download/0.3.0/bazel-0.3.0-installer-linux-x86_64.sh
chmod +x bazel-0.3.0-installer-linux-x86_64.sh
sudo ./bazel-0.3.0-installer-linux-x86_64.sh

export PATH="$PATH:$HOME/bin"

mkdir -p /home/vagrant/src/
cd /home/vagrant/src/
git clone --recurse-submodules https://github.com/tensorflow/serving
cd serving
bazel build tensorflow_serving/...
