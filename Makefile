.PHONY: all

all: run

build:
	docker build -t xebxeb/mlaasos -f Dockerfile.BUILD .

publish:
	docker push xebxeb/mlaasos

run: build
	docker run -itd xebxeb/mlaasos
	./tools/copy.sh
