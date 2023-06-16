#!/bin/bash
sa=$1

# check kubectl context
function contextCheck () {
    currentContext=$(kubectl config current-context | tr '[:upper:]' '[:lower:]')
    if [[ -z "$currentContext" ]]; then
        echo "can't find context, please ensure right context is set"
    elif [[ "$currentContext" == devops* ]] && [[ $sa != shpdevops* ]]; then
        echo "wrong storage account/context combination: context is devops and storage account different form shpdevops"
        echo "please set storage account to prod or change context"
        exit 1
    elif [[ "$currentContext" == devops* ]] && [[ $sa != devstorageaccount* ]]; then
        echo "wrong storage account/context combination: context is devops and storage account different form devstorageaccount"
        echo "please set storage account to dev or change context"
        exit 1
    elif [[ "$currentContext" == apps* ]] && [[ $sa != apps* ]]; then
        echo "wrong storage account/context combination: context is apps and storage account different form apps"
        echo "please set storage account to dev or change context"
        exit 1
    elif [[ "$currentContext" == apps* ]] && [[ $sa != apps* ]]; then
        echo "wrong storage account/context combination: context is apps and storage account different form apps"
        echo "please set storage account to dev or change context"
        exit 1
    elif [[ "$currentContext" == shd-data* ]] && [[ $sa != shddata* ]]; then
        echo "wrong storage account/context combination: context is apps and storage account different form shddata"
        echo "please set storage account to dev or change context"
        exit 1
    elif [[ "$currentContext" == shp-data* ]] && [[ $sa != shpdata* ]]; then
        echo "wrong storage account/context combination: context is apps and storage account different form shpdata"
        echo "please set storage account to dev or change context"
        exit 1
    fi
}

contextCheck
currentContext=$(kubectl config current-context | tr '[:upper:]' '[:lower:]')

echo "updating storage class template for ${sa} ..."
cat storage/storageclass_template.yml | sed "s/<storage_account>/${sa}/" > "storage/storageclass-${sa}.yml"
echo "storage class template update done -> storage/storageclass-${sa}.yml "

echo "deleting default storageclass in cluster $currentContext "
kubectl delete sc default

echo "recreating default storage class in $currentContext via template storage/storageclass-${sa}.yml"
kubectl apply -f "storage/storageclass-${sa}.yml"
