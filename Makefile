.PHONY: all

all: clean \
	build \
	build-export \
	run-export \
	build-inference \
	build-client \
	clean \
	run-inference \
	run-client

DOCKER_CONTAINER_NAME=tf_serving_example
DOCKER_IMAGE_PREFIX=xebxeb/$(DOCKER_CONTAINER_NAME)

# Helpful shortcuts for specifics
client: build-client run-client
inference: build-inference run-inference
export: build-export run-export

clean:
	rm -rf src
	rm -rf mnist_export.tar.gz
	rm -rf mnist_client.tar.gz
	rm -rf mnist_inference.tar.gz
	rm -rf mnist_model.tar.gz

##################### BUILDING #####################
build:
	docker build -t $(DOCKER_IMAGE_PREFIX):build -f Dockerfile.BUILD .

get-build-artifacts: build
	# Remove any BUILD containers
	-docker rm -f $$(docker ps -a --filter "name=$(DOCKER_CONTAINER_NAME).build" | grep -v CONTAINER | awk '{print $$1}')

	# Run the latest BUILD container (but don't use the default CMD which will test everything)
	docker run --name=$(DOCKER_CONTAINER_NAME).build $(DOCKER_IMAGE_PREFIX):build /bin/echo Ran

	# Copy the binary packages that were created from the BUILD
	for ARTIFACT in mnist_export mnist_client mnist_inference; do \
		docker cp $$(docker ps -a --filter "name=$(DOCKER_CONTAINER_NAME).build" | grep -v CONTAINER | awk '{ print $$1 }'):/root/$$ARTIFACT.tar.gz ./ ; \
		tar zxvf $$ARTIFACT.tar.gz ; \
	done

##################### RUN mnist_export to get a model #####################
build-export:
	# Build the export container
	docker build -t $(DOCKER_IMAGE_PREFIX):export -f Dockerfile.EXPORT .

run-export:
	# Remove any export containers
	-docker rm -f $$(docker ps -a --filter "name=$(DOCKER_CONTAINER_NAME).export" | grep -v CONTAINER | awk '{print $$1}')

	# Run another export container to generate a model inside the container
	docker run --name=$(DOCKER_CONTAINER_NAME).export $(DOCKER_IMAGE_PREFIX):export

	# Copy the model.tar.gz that was created from the export
	docker cp $$(docker ps -a --filter "name=$(DOCKER_CONTAINER_NAME).export" | grep -v CONTAINER | head -n 1 | awk '{ print $$1 }'):/root/mnist_export.tar.gz ./

	# Extract the model
	tar zxvf mnist_model.tar.gz

##################### INFERENCE SERVER & CLIENT #####################
build-inference: get-build-artifacts
	# Now build our INFERENCE container
	docker build -t $(DOCKER_IMAGE_PREFIX):inference -f Dockerfile.INFERENCE .

build-client: get-build-artifacts
	# Now build our CLIENT container
	docker build -t $(DOCKER_IMAGE_PREFIX):client -f Dockerfile.CLIENT .

run-inference:
	-docker rm -f $$(docker ps -a --filter "name=$(DOCKER_CONTAINER_NAME).inference" | grep -v CONTAINER | awk '{print $$1}')
	docker run --name=$(DOCKER_CONTAINER_NAME).inference -itd -p 127.0.0.1:30999:30999 $(DOCKER_IMAGE_PREFIX):inference

run-client:
	-docker rm -f $$(docker ps -a --filter "name=$(DOCKER_CONTAINER_NAME).client" | grep -v CONTAINER | awk '{print $$1}')
	docker run --name=$(DOCKER_CONTAINER_NAME).client -it $(DOCKER_IMAGE_PREFIX):client --num_tests=2000 --server=127.0.0.1:30999

##################### SAMPLE TEST #####################

test:
	docker build -t tfserv-test -f Dockerfile.ALL .
	docker run -it tfserv-test

##########################################
