# TensorFlow Serving Examples via Containers
This repository is a set of Dockerfiles and a Makefile to create the necessary artifacts and containers from the [TensorFlow Serving Basic Tutorial](https://tensorflow.github.io/serving/serving_basic).  At some point, I'll work through the advanced tutorial as well.

# Building
To create the necessary containers (including a trained model of MNIST), just simply:
```
make
```
this does assume you at least have Docker installed and an active connection to pull down dependencies.

# Running Local Tests
In order to run a test on a system that uses Docker-Machine (e.g. Mac OS X), run:
```
run-test-docker-machine.sh
```
The above script will run a mnist_inference server, setup an SSH tunnel and then run the mnist_client.

# Running self-contained Tests
If you want to just run the full tutorial within the container, just run ```make test```

# Additional Considerations

## Notable Mentions
- See [tensorflow/serving Issue 114](https://github.com/tensorflow/serving/issues/114) - which was really due to the [grpc/grpc Issue 7133](https://github.com/grpc/grpc/issues/7133), I had to download the master branch of gRPC to pick up a recent bug fix.
- Because of the above, gRPC is installed from scratch on the client Docker image
- You can change the docker image prefix just by updating *image-name.config*

## Types of Dockerfiles
There are four Dockerfiles in the repository.

- *Dockerfile.BUILD* - sets up all build components, run the necessary bazel builds and then tar the assets so they can be copied out of the container
- *Dockerfile.EXPORT* - executes mnist_export script and tar the generated model
- *Dockerfile.INFERENCE* - executes mnist_inference but needs a model.  The current implementation assumes artifacts/mnist_model.tar.gz exists
- *Dockerfile.CLIENT* - executes mnist_client for a given server address (specified via ```--server```) and outputs the error rate
