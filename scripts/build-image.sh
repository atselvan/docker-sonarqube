#!/bin/bash

# Variables
USERNAME="allanselvan"
IMAGE="sonarqube"
TAGNAME="$USERNAME/$IMAGE"
VERSION=`cat VERSION`

echo "Building new image with tag: $TAGNAME"
docker build -t $TAGNAME:latest ../
docker tag $TAGNAME:latest $TAGNAME:$VERSION