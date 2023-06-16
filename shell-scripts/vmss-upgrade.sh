#!/bin/bash

sp=$1
pass=$2
tenant_id=$3
sub_id=$4
ENV=$5
region=$6
name=$7

# az cli connection
az login --service-principal --username $sp --password $pass --tenant ${tenant_id} > /dev/null
az account set --subscription $sub_id

#vmss name
version=$(head -n 1 .version | sed "s/\./-/g")

vmss="$version-vendor-$name-$region"

rg="$version-$ENV-vendor-RG-$region"


#update vmss
az vmss update-instances --instance-ids "*" --name $vmss --resource-group $rg --subscription $sub_id
