#!/bin/bash

function usage() {
    echo "usage :"
    echo "  make.sh ACTION"
    echo ""
    echo "example :"
    echo "  make.sh build"
    echo ""
    echo "available actions list :"
    echo "  build "
    echo "  push "
}

source .env

action=$1
image_name="ansibleAz"
image_tag="$image_name:$IMAGE_VERSION"
image_latest="$image_name:latest"
docker_repo="$repo/$image_name"

if [ "$action" == "build" ]; then
    
    docker build --build-arg BUILD_DATE=`date -u +”%H:%M:%S-%d/%m/%Y”` --build-arg VERSION=$IMAGE_VERSION -t $image_tag -t $image_latest .

elif [ "$action" == "push" ]; then
    
    docker tag $image_tag $docker_repo:$IMAGE_VERSION
    docker tag $image_latest $docker_repo:latest
    docker push $docker_repo:$IMAGE_VERSION
    docker push $docker_repo:latest

fi