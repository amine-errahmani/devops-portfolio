#!/bin/bash

sp=$1
pass=$2
tenant_id=$3
sub_id=$4
ENV=$5
region=$6

# az cli connection
az login --service-principal --username $sp --password $pass --tenant ${tenant_id} > /dev/null
az account set --subscription $sub_id

#vmss and rt-vm names
version=$(head -n 1 .version | sed "s/\./-/g")
vmss="$version-vendor-app2-$region"
rt_vm="vendor-app2-rt-$region"
batch_vm="vendor-app2-b-$region"
rg="$version-$ENV-vendor-RG-$region"


#list vmss instances and vms ips
nics=$(az vmss nic list --vmss-name $vmss --resource-group $rg --subscription $sub_id)
ips=$(echo $nics | jq -r '.[].ipConfigurations[].privateIpAddress')
rt_ip=$(az vm list-ip-addresses -g $rg -n $rt_vm | jq -r '.[].virtualMachine.network.privateIpAddresses[]')
batch_ip=$(az vm list-ip-addresses -g $rg -n $batch_vm | jq -r '.[].virtualMachine.network.privateIpAddresses[]')

#create ip list
declare -a ip_list
j=1
for i in $ips
do
    ip_list[$j]=$i
    j=$(( j+1 ))
done
ip_list[$j]=$rt_ip


#connect to batch vm and apply config

scp -o StrictHostKeyChecking=no -i appuser_ssh_key ./ansible/app2/app/app2-batch-post.yml appuser@$batch_ip:/tmp/app2-batch-post.yml
ssh -o StrictHostKeyChecking=no -i appuser_ssh_key appuser@$batch_ip "ansible-playbook /tmp/app2-batch-post.yml -e 'rt1=${ip_list[1]}' -e 'rt2=${ip_list[2]}' -e 'rt3=${ip_list[3]}' | tee -a /tmp/app2-post.log"

# wait for batch server start
sleep 1m

#connect to realtime vms and apply config
for i in "${!ip_list[@]}"
do
    scp -o StrictHostKeyChecking=no -i appuser_ssh_key ./ansible/app2/app/app2-rt-post.yml appuser@${ip_list[$i]}:/tmp/app2-rt-post.yml
    ssh -o StrictHostKeyChecking=no -i appuser_ssh_key appuser@${ip_list[$i]} "ansible-playbook /tmp/app2-rt-post.yml -e \"index=$i\" | tee -a /tmp/app2-post.log"
done 

