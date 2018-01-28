#!/bin/bash

# Variables
USERNAME="allanselvan"
NAME="sonarqube"
VERSION=`cat VERSION`
IMAGE="$USERNAME/$NAME:${VERSION}"
VOLUME="source=/data/$NAME,target=/appl/sonarqube/data"
NETWORK="privatesquare"
PORT="9000:9000"

EXISTING=`docker service ls | grep -c $NAME`
if [ $EXISTING -gt 0 ]
then
   echo "Removing $NAME service"
   docker service rm $NAME
fi

echo "Running a new service with name $NAME"
echo "[INFO] IMAGE   : $IMAGE"
echo "[INFO] NAME    : $NAME"
echo "[INFO] VOLUME  : $VOLUME"
echo "[INFO] NETWORK : $NETWORK"
echo "[INFO] PORT    : $PORT"

docker service create \
    --name=$NAME \
    --replicas 1 \
    --network privatesquare \
    --publish=$PORT/tcp \
    --detach=true \
    --constraint=node.role==manager \
    --mount=type=bind,$VOLUME\
    --secret source=mysql_password,target=mysql_password \
    -e SONARQUBE_JDBC_PASSWORD_FILE="/run/secrets/mysql_password" \
    $IMAGE