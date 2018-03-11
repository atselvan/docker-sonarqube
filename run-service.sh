#!/bin/bash

# Variables
USERNAME="allanselvan"
NAME="sonarqube"
VERSION=`cat VERSION`
IMAGE="$USERNAME/$NAME:${VERSION}"
VOLUME="source=/Users/allanselvan/data/$NAME,target=/appl/sonarqube/data"
NETWORK="privatesquare"
PORT="9000:9000"
SONARQUBE_JDBC_URL="jdbc:mysql://192.168.178.2:3306/sonarqube?useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true&useConfigs=maxPerformance"
LDAP_URL='ldap://192.168.178.23:10389'
LDAP_BIND_DN="cn=root,dc=privatesquare,dc=in"

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
    --secret source=ldap_password,target=ldap_password \
    -e SONARQUBE_JDBC_URL=$SONARQUBE_JDBC_URL \
    -e SONARQUBE_JDBC_PASSWORD_FILE="/run/secrets/mysql_password" \
    -e LDAP_URL=$LDAP_URL \
    -e LDAP_BIND_DN=$LDAP_BIND_DN \
    -e LDAP_PASSWORD_FILE="/run/secrets/ldap_password" \
    $IMAGE