#!/bin/bash
DOCKER_IMAGE_NAME=`cat image-name.config`
echo Using $DOCKER_IMAGE_NAME as image name
ACTIVE_MACHINE=`docker-machine active`
ACTIVE_IP=`docker-machine ip $ACTIVE_MACHINE`
echo Starting SSH tunnel
docker-machine ssh $ACTIVE_MACHINE -N -L 9000:localhost:9000 &
CHILD_PID=$!
echo $CHILD_PID of SSH tunnel
docker run -itd -p 9000:9000 --name=server $DOCKER_IMAGE_NAME:inference # will listen on port 9000
docker run -it $DOCKER_IMAGE_NAME:client --server=$ACTIVE_IP:9000
docker rm -f server
kill -9 $CHILD_PID
