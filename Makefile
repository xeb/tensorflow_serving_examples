.PHONY: all

all: clean client inference

DOCKER_IMAGE_PREFIX=`cat image-name.config`
DOCKER_CONTAINER_NAME=tf_serving_example

clean:
	rm -rf artifacts

##################### BUILDING #####################
build:
	docker build -t $(DOCKER_IMAGE_PREFIX):build -f Dockerfile.BUILD .

get-build-artifacts: build
	# Let's work in an artifacts directory
	mkdir -p artifacts

	# Remove any BUILD containers
	-docker rm -f $$(docker ps -a --filter "name=$(DOCKER_CONTAINER_NAME).build" | grep -v CONTAINER | awk '{print $$1}')

	# Run the latest BUILD container (but don't use the default CMD which will test everything)
	docker run --name=$(DOCKER_CONTAINER_NAME).build $(DOCKER_IMAGE_PREFIX):build /bin/echo Ran

	# Copy the binary packages that were created from the BUILD
	for ARTIFACT in mnist_export mnist_client mnist_inference; do \
		docker cp $$(docker ps -a --filter "name=$(DOCKER_CONTAINER_NAME).build" | grep -v CONTAINER | awk '{ print $$1 }'):/root/$$ARTIFACT.tar.gz ./artifacts/ ; \
	done


##################### RUN mnist_export to get a model #####################
build-export: get-build-artifacts
	# Build the export container
	docker build -t $(DOCKER_IMAGE_PREFIX):export -f Dockerfile.EXPORT .

run-export: build-export
	# Remove any export containers
	-docker rm -f $$(docker ps -a --filter "name=$(DOCKER_CONTAINER_NAME).export" | grep -v CONTAINER | awk '{print $$1}')

	# Run another export container to generate a model inside the container
	docker run --name=$(DOCKER_CONTAINER_NAME).export $(DOCKER_IMAGE_PREFIX):export

	# Copy the model.tar.gz that was created from the export
	docker cp $$(docker ps -a --filter "name=$(DOCKER_CONTAINER_NAME).export" | grep -v CONTAINER | head -n 1 | awk '{ print $$1 }'):/root/mnist_model.tar.gz ./artifacts/

##################### INFERENCE SERVER & CLIENT #####################
inference: run-export
	# Now build our INFERENCE container
	docker build -t $(DOCKER_IMAGE_PREFIX):inference -f Dockerfile.INFERENCE .

client: get-build-artifacts
	# Now build our CLIENT container
	docker build -t $(DOCKER_IMAGE_PREFIX):client -f Dockerfile.CLIENT .

##################### SAMPLE TEST #####################

test: build
	docker run -it $(DOCKER_IMAGE_PREFIX):build

##########################################
