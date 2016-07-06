#!/bin/bash
export IMAGE_ID=$(docker ps | grep mlaasos | awk '{ print $1 }')
echo "Getting from $IMAGE_ID"
docker cp $IMAGE_ID:/src/serving/tensorflow_serving-examples.tar.gz tensorflow_serving-examples.tar.gz
