#!/bin/bash

function usage() {
    echo "usage :"
    echo "  make.sh ACTION"
    echo ""
    echo "example :"
    echo "  make.sh build"
    echo ""
    echo "available actions list :"
    echo "  build  --  creates thanos secret based on file located in thanos/thanos-storage-config-ENV.yaml"
    echo "  push  -- deletes the secret named thanos-objstore-config fro; the cluster"
}

source .env

action=$1
image_name="helmKubeVault"
image_tag="$image_name:$IMAGE_VERSION"
image_latest="$image_name:latest"
docker_repo=".jfrog.io/$image_name"

if [ "$action" == "build" ]; then
    
    docker build \
        --build-arg BUILD_DATE=`date -u +”%H:%M:%S-%d/%m/%Y”` \
        --build-arg VERSION=$IMAGE_VERSION \
        --build-arg YQ_VERSION=$YQ_VERSION \
        --build-arg VAULT_VERSION=$VAULT_VERSION \
        --build-arg HELM_SECRETS_VERSION=$HELM_SECRETS_VERSION \
        --build-arg HELM_VERSION=$HELM_VERSION \
        --build-arg KUBE_VERSION=$KUBE_VERSION \
        -t $image_tag \
        -t $image_latest \
        .

elif [ "$action" == "push" ]; then
    
    docker tag $image_tag $docker_repo:$IMAGE_VERSION
    docker tag $image_latest $docker_repo:latest
    docker push $docker_repo:$IMAGE_VERSION
    docker push $docker_repo:latest

fi