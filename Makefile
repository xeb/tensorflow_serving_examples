.PHONY: all

all: run

build:
	docker build -t xebxeb/mlaasos:build -f Dockerfile.BUILD .
	docker run -itd xebxeb/mlaasos:build
	./tools/copy.sh
	docker build -t xebxeb/mlaasos:run -f Dockerfile.RUN .
	rm -rf bazel-bin

publish:
	docker push xebxeb/mlaasos

run: build
	docker run -it xebxeb/mlaasos:run /bin/bash
