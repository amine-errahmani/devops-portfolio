#!/bin/bash

sp=$1
pass=$2
tenant_id=$3
sub_id=$4
ENV=$5
region=$6
module=$7
# versionfile=$8

# az cli connection
az login --service-principal --username $sp --password $pass --tenant ${tenant_id} > /dev/null
az account set --subscription $sub_id


#set version to deploy
# if [ $versionfile == "new" ] || [ $versionfile == "current" ] || [ $versionfile == "old" ] && [ -f ".version_$versionfile" ]; then
#     cat ".version_$versionfile" > .version
# else
#     echo "Error: .version_$versionfile is not a valid version file"
#     exit 1
# fi



moduleU=`echo "$module" | tr '[:lower:]' '[:upper:]'`
version=$(head -n 1 terraform/$moduleU/.version | sed "s/\./-/g")
shortversion=`echo $version | sed 's/-//g' | sed 's/v//g'`
rg="$version-$ENV-vendor-$module-RG-$region"


if [ $ENV == "prp" ]; then
    shortenv="r"
else
    shortenv=`echo "${ENV:0:1}" | tr '[:upper:]' '[:lower:]'`
fi


case $module in
    app2)
        vmss="${shortenv}${shortversion}app2${region}"
        batch="${shortenv}${shortversion}app2ui${region}"

        nics=$(az vmss nic list --vmss-name $vmss --resource-group $rg)
        vmss_ips=$(echo $nics | jq -r '.[].ipConfigurations[].privateIpAddress')
        
        for i in $vmss_ips
        do
            ansible-playbook ansible/inventory/add-to-inventory-ip.yml -e "host=$i" \
                                                                    -e "group=app2_ss_$region" \
                                                                    -e "env=$ENV" \
                                                                    -e "version=current"
        done
                    
        batch_ip=$(az vm list-ip-addresses -g $rg -n $batch | jq -r '.[].virtualMachine.network.privateIpAddresses[]')
        
        ansible-playbook ansible/inventory/add-to-inventory-ip.yml -e "host=$batch_ip" \
                                                                -e "group=app2_batch_$region" \
                                                                -e "env=$ENV" \
                                                                -e "version=current"
        ;;
    app1)
        vmss="${shortenv}${shortversion}app1${region}"
        app1_batch="${shortenv}${shortversion}app1batch${region}"

        nics=$(az vmss nic list --vmss-name $vmss --resource-group $rg)
        vmss_ips=$(echo $nics | jq -r '.[].ipConfigurations[].privateIpAddress')

        for i in $vmss_ips
        do
            ansible-playbook ansible/inventory/add-to-inventory-ip.yml -e "host=$i" \
                                                                    -e "group=app1_ss_$region" \
                                                                    -e "env=$ENV" \
                                                                    -e "version=current"
        done
                    
        app1_batch_ip=$(az vm list-ip-addresses -g $rg -n $app1_batch | jq -r '.[].virtualMachine.network.privateIpAddresses[]')
        ansible-playbook ansible/inventory/add-to-inventory-ip.yml -e "host=$app1_batch_ip" \
                                                                -e "group=app1_batch_$region" \
                                                                -e "env=$ENV" \
                                                                -e "version=current"
        ;;
    app3)
        if [ $ENV == "prp" ]; then

            app3="${shortenv}${shortversion}app3${region}"
            app3_ip=$(az vm list-ip-addresses -g $rg -n $app3 | jq -r '.[].virtualMachine.network.privateIpAddresses[]')
            ansible-playbook ansible/inventory/add-to-inventory-ip.yml -e "host=$app3_ip" \
                                                                -e "group=app3_$region" \
                                                                -e "env=$ENV" \
                                                                -e "version=current"

        else
            solr="${shortenv}${shortversion}app3s${region}"

            solr_nics=$(az vmss nic list --vmss-name $solr --resource-group $rg)
            solr_ips=$(echo $solr_nics | jq -r '.[].ipConfigurations[].privateIpAddress')

            for i in $solr_ips
            do
                ansible-playbook ansible/inventory/add-to-inventory-ip.yml -e "host=$i" \
                                                                        -e "group=solr_servers_${region}" \
                                                                        -e "env=$ENV" \
                                                                        -e "version=current"
            done


            neo4j="${shortenv}${shortversion}app3n${region}"

            neo4j_nics=$(az vmss nic list --vmss-name $neo4j --resource-group $rg)
            neo4j_ips=$(echo $neo4j_nics | jq -r '.[].ipConfigurations[].privateIpAddress')

            for j in $neo4j_ips
            do
                ansible-playbook ansible/inventory/add-to-inventory-ip.yml -e "host=$j" \
                                                                        -e "group=neo4j_servers_${region}" \
                                                                        -e "env=$ENV" \
                                                                        -e "version=current"
            done

            karaf="${shortenv}${shortversion}app3k${region}"

            karaf_nics=$(az vmss nic list --vmss-name $karaf --resource-group $rg)
            karaf_ips=$(echo $karaf_nics | jq -r '.[].ipConfigurations[].privateIpAddress')

            for k in $karaf_ips
            do
                ansible-playbook ansible/inventory/add-to-inventory-ip.yml -e "host=$k" \
                                                                        -e "group=karaf_servers_${region}" \
                                                                        -e "env=$ENV" \
                                                                        -e "version=current"
            done
        fi
        ;;
esac
