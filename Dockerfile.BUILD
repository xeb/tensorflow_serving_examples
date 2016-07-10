# Original Dockerfile from: https://github.com/tensorflow/serving/blob/master/tensorflow_serving/tools/docker/Dockerfile.devel
FROM ubuntu:14.04

RUN apt-get update && apt-get install -y \
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
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fSsL -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py

# Set up grpc from the master branch

RUN pip install enum34 futures six && \
    pip install --pre protobuf>=3.0.0a3

RUN git clone -b master https://github.com/grpc/grpc /src/grpc
WORKDIR /src/grpc
RUN git submodule update --init

# For the next two commands do `sudo pip install` if you get permission-denied errors
RUN pip install -rrequirements.txt
RUN GRPC_PYTHON_BUILD_WITH_CYTHON=1 pip install .


# Set up Bazel.

# We need to add a custom PPA to pick up JDK8, since trusty doesn't
# have an openjdk8 backport.  openjdk-r is maintained by a reliable contributor:
# Matthias Klose (https://launchpad.net/~doko).  It will do until
# we either update the base image beyond 14.04 or openjdk-8 is
# finally backported to trusty; see e.g.
#   https://bugs.launchpad.net/trusty-backports/+bug/1368094
RUN add-apt-repository -y ppa:openjdk-r/ppa && \
    apt-get update && \
    apt-get install -y openjdk-8-jdk openjdk-8-jre-headless && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Running bazel inside a `docker build` command causes trouble, cf:
#   https://github.com/bazelbuild/bazel/issues/134
# The easiest solution is to set up a bazelrc file forcing --batch.
RUN echo "startup --batch" >>/root/.bazelrc
# Similarly, we need to workaround sandboxing issues:
#   https://github.com/bazelbuild/bazel/issues/418
RUN echo "build --spawn_strategy=standalone --genrule_strategy=standalone" \
    >>/root/.bazelrc
ENV BAZELRC /root/.bazelrc
# Install the most recent bazel release.
ENV BAZEL_VERSION 0.2.0
WORKDIR /
RUN mkdir /bazel && \
    cd /bazel && \
    curl -fSsL -O https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
    curl -fSsL -o /bazel/LICENSE.txt https://raw.githubusercontent.com/bazelbuild/bazel/master/LICENSE.txt && \
    chmod +x bazel-*.sh && \
    ./bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
    cd / && \
    rm -f /bazel/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh

RUN mkdir -p /src/ && \
    cd /src && \
    git clone --recurse-submodules https://github.com/tensorflow/serving

WORKDIR /src/serving/tensorflow/

# We need to configure Python in order for Bazel to build correctly
RUN ./util/python/python_config.sh --setup "$(which python)"

WORKDIR /src/serving/

# Replace the 0.0.0.0 address in mnist_inference.cc
RUN sed -i.backup s/0\.0\.0\.0/\*/g /src/serving/tensorflow_serving/example/mnist_inference.cc

# If you want to build everything, do this:
# RUN bazel build tensorflow_serving/...

# Let's just build what we need
RUN bazel build //tensorflow_serving/example:mnist_inference
RUN bazel build //tensorflow_serving/example:mnist_client
RUN bazel build //tensorflow_serving/example:mnist_export

# Make a test script
RUN echo '#!/bin/bash\n\
mkdir -p /models\n\
cd /src/serving/bazel-bin/tensorflow_serving/example/\n\
./mnist_export --training_iteration=1000 /models\n\
./mnist_inference --port=9000 /models/00000001 & \n\
./mnist_client --server=localhost:9000 \n\
\n'\
>> /root/test.sh
RUN chmod +x /root/test.sh

# Create artifacts to be exported, specifically: mnist_inference, mnist_client and mnist_export
WORKDIR /root
RUN tar cvf mnist_inference.tar.gz /src/serving/bazel-bin/tensorflow_serving/example/mnist_inference*
RUN tar cvf mnist_client.tar.gz /src/serving/bazel-bin/tensorflow_serving/example/mnist_client*
RUN tar cvf mnist_export.tar.gz /src/serving/bazel-bin/tensorflow_serving/example/mnist_export*

# Default CMD is to do a test
CMD [ "/root/test.sh" ]
