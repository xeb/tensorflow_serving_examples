FROM ubuntu:xenial


MAINTAINER Mark Kockerbeck <mark@kockerbeck.com>

RUN apt-get update -y
RUN apt-get install -y \
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
        zlib1g-dev; apt-get clean all
RUN apt-get install -y \
        wget \
        default-jdk default-jre \
        ; apt-get clean all
RUN mkdir -p /tmp/downloads
WORKDIR /tmp/downloads
RUN wget https://github.com/bazelbuild/bazel/releases/download/0.3.0/bazel-0.3.0-installer-linux-x86_64.sh
RUN chmod +x bazel-0.3.0-installer-linux-x86_64.sh
RUN ./bazel-0.3.0-installer-linux-x86_64.sh

RUN PATH="$PATH:$HOME/bin"

RUN mkdir -p /src/
WORKDIR /src/
RUN git clone --recurse-submodules https://github.com/tensorflow/serving
WORKDIR /src/serving/
#RUN wget https://github.com/tensorflow/serving/archive/0.4.1.zip
#RUN unzip 0.4.1.zip
#RUN mv serving-0.4.1 serving
#WORKDIR /src/serving/tensorflow
#RUN wget https://github.com/tensorflow/tensorflow/archive/v0.9.0.zip
#RUN unzip v0.9.0.zip
#RUN mv tensorflow-0.9.0/* ./; rm -f v0.9.0.zip; rm -rf tensorflow-0.9.0/
ADD scripts/build.sh ./build.sh
# RUN bazel build tensorflow_serving/...

ENTRYPOINT /bin/bash
