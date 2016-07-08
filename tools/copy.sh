#!/bin/bash
export IMAGE_ID=$(docker ps | grep mlaasos | head -n 1 | awk '{ print $1 }')
echo "Getting 'tensorflow_serving-examples.tar.gz' from $IMAGE_ID"
docker cp $IMAGE_ID:/src/serving/tensorflow_serving-examples.tar.gz ./
tar zxvf tensorflow_serving-examples.tar.gz
rm -rf tensorflow_serving-examples.tar.gz
