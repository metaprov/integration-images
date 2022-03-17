#!/bin/bash
if [ -z "$1" ]; then
	TAG_LATEST="ghcr.io/metaprov/kind-modela"
else
	TAG_LATEST=$1
fi

if [ -z "$2" ]; then
	TAG_VERSION="1.0"
else
	TAG_VERSION=$2
fi

if [ -z "$KIND_IMAGE" ]; then
	KIND_IMAGE="bsycorp/kind:latest-1.21"
	echo "Defaulting KinD image to $KIND_IMAGE"
fi

function finish {
  echo "Cleanup"
  docker rm -f $CONTAINER_ID
  docker volume prune -f | true
}
trap finish EXIT


CONTAINER_ID=$(docker run -d -it --cpus="2" --memory="8g" --privileged $KIND_IMAGE)
echo "KinD container = $CONTAINER_ID"
docker cp ./install-modela.sh $CONTAINER_ID:/install-modela.sh
docker cp ./cache-image.sh $CONTAINER_ID:/cache-image.sh
docker cp ./dockerd-entrypoint.sh $CONTAINER_ID:/dockerd-entrypoint.sh
docker cp ./supervisord.conf $CONTAINER_ID:/supervisord.conf
docker exec -it $CONTAINER_ID /bin/bash -c /install-modela.sh
docker cp ./start.sh $CONTAINER_ID:/start.sh


echo "Commiting new container"
docker commit \
	-c 'EXPOSE 8080/tcp' \
	-c 'EXPOSE 8081/tcp' \
	-c 'EXPOSE 9001/tcp' \
	-c 'EXPOSE 8095/tcp' \
	-c 'EXPOSE 9000/tcp' \
	$CONTAINER_ID $TAG_LATEST

docker tag $TAG_LATEST $TAG_VERSION
