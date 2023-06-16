#!/bin/bash
module=$1
shortenv=$2
switch=$3


### examples of use
#
#   ./dns.sh module environment switch
#       module = should be the module targeted by the dns update
#       environment = consists of one letter for the environment targeted (d for dev, u for test, p for prod)    
#       switch = to switch the existing addresses to the -old records, doesn't matter what's the value, the script only check if the input is not empty 
#   
#   ./dns.sh app3 u yes ==> update app3 records in test environment while switching old records
#
#   ./dns.sh app2 p switch ==> update app2 records in prod environment while switching old records
#
#   ./dns.sh app4 d  ==> update app4 records in dev environment without switching old records

# ### Pre-requisites 
#   export following varibales   
#
#       $ARM_CLIENT_ID
#       $ARM_CLIENT_SECRET
#       $ARM_TENANT_ID
#       $TF_VAR_subscription_id_dev



### define colors ###
RED="\033[1;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
PURPLE="\033[1;35m"
CYAN="\033[1;36m"
WHITE="\033[1;37m"
RESET="\033[0m"

### initialise Azure access creds ###
sp=$ARM_CLIENT_ID
pass=$ARM_CLIENT_SECRET
tenant_id=$ARM_TENANT_ID
sub_id=$TF_VAR_subscription_id_dev



### validate target module ###
if [ $module == "app3" ] || [ $module == "app2" ] || [ $module == "app1" ] || [ $module == "app4" ]; then

    FILE="terraform/$module/.version"

else
    echo "----------------------------------------------------"
    echo -e "| ${RED} No Valid Module specified ${RESET}"
    echo "----------------------------------------------------"
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo "Error: $FILE does not exist"
    exit 1
fi


### define env and domain ###
case $shortenv in
    d)
        ENV="dev"
        zone="vm.infra"
        zone_rg="network-rg"
        domain="dev.app"
        ;;
    u)
        ENV="test"
        zone="vm.infra"
        zone_rg="network-rg"
        domain="test.app"
        ;;
    p)
        ENV="prd"
        zone="vm.infra"
        zone_rg=""
        domain="prd.app"
        ;;
    *)
        echo "----------------------------------------------------"
        echo -e "| ${RED} No Valid Module specified ${RESET}"
        echo "----------------------------------------------------"
        exit 1
        ;;
esac


### define resources infos ###
version=$(head -n 1 $FILE | sed "s/\./-/g")
shortversion=`echo $version | sed 's/-//g' | sed 's/v//g'`
rg_n="$version-$ENV-vendor-$module-rg-n"
rg_c="$version-$ENV-vendor-$module-rg-c"

## resources names

#north
app2_batch_n="${shortenv}${shortversion}imui01n"
app2_ss_n="${shortenv}${shortversion}imimn"
app1_ss_n="${shortenv}${shortversion}imadn"
karaf_ss_n="${shortenv}${shortversion}imckn"
neo4j_ss_n="${shortenv}${shortversion}imcnn"
solr_ss_n="${shortenv}${shortversion}imcsn"
app4_n="${shortenv}${shortversion}imsr01n"

#central
app2_batch_c="${shortenv}${shortversion}imui01n"
app2_ss_c="${shortenv}${shortversion}imimn"
app1_ss_c="${shortenv}${shortversion}imadn"
karaf_ss_c="${shortenv}${shortversion}imckn"
neo4j_ss_c="${shortenv}${shortversion}imcnn"
solr_ss_c="${shortenv}${shortversion}imcsn"
app4_c="${shortenv}${shortversion}imsr01n"


# aliases lists
declare -a app2_ss_aliases=("app2-1" "app2-2" "app2-3")
declare -a app1_ss_aliases=("app1-1" "app1-2")
declare -a karaf_ss_aliases=("karaf-1" "karaf-2" "karaf-3")
declare -a neo4j_ss_aliases=("neo4j-1" "neo4j-2")
declare -a solr_ss_aliases=("solr-1" "solr-2")
app2_batch_alias="app2-batch"
app4_alias="app4"


### Functions ###

UpdateARecord(){
    rg=$1
    zone=$2
    alias=$3
    domain=$4
    target=$5
    switch=$6
    old_record="$alias-old.$domain"
    current_record="$alias.$domain"
    new_record="$alias-new.$domain"

    current_record_ip=$(az network private-dns record-set a show -g $rg -z $zone -n $current_record --query "aRecords[].ipv4Address[]" | jq -r '.[]')
    new_record_ip=$(az network private-dns record-set a show -g $rg -z $zone -n $old_record --query "aRecords[].ipv4Address[]" | jq -r '.[]')


    # old record
    if [ $switch ];then
        old_record_ip=$(az network private-dns record-set a show -g $rg -z $zone -n $old_record --query "aRecords[].ipv4Address[]" | jq -r '.[]')
        az network private-dns record-set a remove-record -a $old_record_ip -g $rg -z $zone -n $old_record --keep-empty-record-set --output none
        az network private-dns record-set a add-record -g $rg -z $zone -n $old_record -a $current_record_ip | jq '.aRecords, .fqdn'
    fi

    # current record
    
    az network private-dns record-set a remove-record -g $rg -z $zone -n $current_record -a $current_record_ip --keep-empty-record-set --output none
    az network private-dns record-set a add-record -g $rg -z $zone -n $current_record -a $target | jq '.aRecords, .fqdn'

    # new record
    az network private-dns record-set a remove-record -g $rg -z $zone -n $new_record -a $new_record_ip --keep-empty-record-set --output none
    az network private-dns record-set a add-record -g $rg -z $zone -n $new_record -a $target | jq '.aRecords, .fqdn' 
}


# az cli connection
az login --service-principal --username $sp --password $pass --tenant ${tenant_id} > /dev/null
az account set --subscription $sub_id



case $module in
    app2)
        case $shortenv in
            d | s)
                nics=$(az vmss nic list --vmss-name $app2_ss_n --resource-group $rg_n)
                vmss_ips=$(echo $nics | jq -r '.[].ipConfigurations[].privateIpAddress')

                # vmss
                j=1
                for ip in $vmss_ips
                do
                    updateARecord $zone_rg $zone "${app2_ss_aliases[$j]}-n" $domain $ip $switch
                    j+=1
                done

                # vm
                batch_ip=$(az vm list-ip-addresses -g $rg_n -n $app2_batch_n | jq -r '.[].virtualMachine.network.privateIpAddresses[]')
                updateARecord $zone_rg $zone "$app2_batch_alias-n" $domain $batch_ip $switch
                ;;
            u | r | p)
                ## North ##
                    nics_n=$(az vmss nic list --vmss-name $app2_ss_n --resource-group $rg_n)
                    vmss_ips_n=$(echo $nics_n | jq -r '.[].ipConfigurations[].privateIpAddress')

                    # vmss
                    j=1
                    for ip in $vmss_ips_n
                    do
                        updateARecord $zone_rg $zone "${app2_ss_aliases[$j]}-n" $domain $ip $switch
                        j+=1
                    done

                    # vm
                    batch_ip_n=$(az vm list-ip-addresses -g $rg_n -n $app2_batch_n | jq -r '.[].virtualMachine.network.privateIpAddresses[]')
                    updateARecord $zone_rg $zone "$app2_batch_alias-n" $domain $batch_ip_n $switch

                ## Central ##
                    nics_c=$(az vmss nic list --vmss-name $app2_ss_c --resource-group $rg_c)
                    vmss_ips_c=$(echo $nics_c | jq -r '.[].ipConfigurations[].privateIpAddress')

                    # vmss
                    k=1
                    for ip in $vmss_ips_c
                    do
                        updateARecord $zone_rg $zone "${app2_ss_aliases[$k]}-c" $domain $ip $switch
                        k+=1
                    done

                    # vm
                    batch_ip_c=$(az vm list-ip-addresses -g $rg_c -n $app2_batch_c | jq -r '.[].virtualMachine.network.privateIpAddresses[]')
                    updateARecord $zone_rg $zone "$app2_batch_alias-c" $domain $batch_ip_c $switch
                ;;
        esac
        ;;
    app1)
        case $shortenv in
            d | s)
                nics_n=$(az vmss nic list --vmss-name $app1_ss_n --resource-group $rg_n)
                vmss_ips_n=$(echo $nics_n | jq -r '.[].ipConfigurations[].privateIpAddress')

                # vmss
                j=1
                for ip in $vmss_ips_n
                do
                    updateARecord $zone_rg $zone "${app1_ss_aliases[$j]}-n" $domain $ip $switch
                    j+=1
                done
                ;;

            u | r | p)
                ## North ##
                    nics_n=$(az vmss nic list --vmss-name $app1_ss_n --resource-group $rg_n)
                    vmss_ips_n=$(echo $nics_n | jq -r '.[].ipConfigurations[].privateIpAddress')

                    # vmss
                    j=1
                    for ip in $vmss_ips_n
                    do
                        updateARecord $zone_rg $zone "${app1_ss_aliases[$j]}-n" $domain $ip $switch
                        j+=1
                    done
                ## Central ##
                    nics_c=$(az vmss nic list --vmss-name $app1_ss_c --resource-group $rg_c)
                    vmss_ips_c=$(echo $nics_c | jq -r '.[].ipConfigurations[].privateIpAddress')

                    # vmss
                    k=1
                    for ip in $vmss_ips_c
                    do
                        updateARecord $zone_rg $zone "${app1_ss_aliases[$k]}-c" $domain $ip $switch
                        k+=1
                    done

                ;;
        esac
        ;;
    app3)
        case $shortenv in
            d | s)
                # solr
                solr_nics_n=$(az vmss nic list --vmss-name $solr_ss_n --resource-group $rg_n)
                solr_ips_n$(echo $solr_nics_n | jq -r '.[].ipConfigurations[].privateIpAddress')

                j=1
                for ip in $solr_ips_n
                do
                    updateARecord $zone_rg $zone "${solr_ss_aliases[$j]}-n" $domain $ip $switch
                    j+=1
                done

                # neo4j
                neo4j_nics_n=$(az vmss nic list --vmss-name $neo4j_ss_n --resource-group $rg_n)
                neo4j_ips_n=$(echo $neo4j_nics_n | jq -r '.[].ipConfigurations[].privateIpAddress')

                j=1
                for ip in $neo4j_ips_n
                do
                    updateARecord $zone_rg $zone "${neo4j_ss_aliases[$j]}-n" $domain $ip $switch
                    j+=1
                done

                # karaf
                karaf_nics_n=$(az vmss nic list --vmss-name $karaf_ss_n --resource-group $rg_n)
                karaf_ips_n=$(echo $karaf_nics_n | jq -r '.[].ipConfigurations[].privateIpAddress')

                j=1
                for ip in $karaf_ips_n
                do
                    updateARecord $zone_rg $zone "${karaf_ss_aliases[$j]}-n" $domain $ip $switch
                    j+=1
                done

            ;;
            u | r | p)
                ## North ##
                     # solr
                    solr_nics_n=$(az vmss nic list --vmss-name $solr_ss_n --resource-group $rg_n)
                    solr_ips_n$(echo $solr_nics_n | jq -r '.[].ipConfigurations[].privateIpAddress')

                    j=1
                    for ip in $solr_ips_n
                    do
                        updateARecord $zone_rg $zone "${solr_ss_aliases[$j]}-n" $domain $ip $switch
                        j+=1
                    done

                    # neo4j
                    neo4j_nics_n=$(az vmss nic list --vmss-name $neo4j_ss_n --resource-group $rg_n)
                    neo4j_ips_n=$(echo $neo4j_nics_n | jq -r '.[].ipConfigurations[].privateIpAddress')

                    j=1
                    for ip in $neo4j_ips_n
                    do
                        updateARecord $zone_rg $zone "${neo4j_ss_aliases[$j]}-n" $domain $ip $switch
                        j+=1
                    done

                    # karaf
                    karaf_nics_n=$(az vmss nic list --vmss-name $karaf_ss_n --resource-group $rg_n)
                    karaf_ips_n=$(echo $karaf_nics_n | jq -r '.[].ipConfigurations[].privateIpAddress')

                    j=1
                    for ip in $karaf_ips_n
                    do
                        updateARecord $zone_rg $zone "${karaf_ss_aliases[$j]}-n" $domain $ip $switch
                        j+=1
                    done

                ## Central ##
                    # solr
                    solr_nics_c=$(az vmss nic list --vmss-name $solr_ss_c --resource-group $rg_c)
                    solr_ips_c$(echo $solr_nics_c | jq -r '.[].ipConfigurations[].privateIpAddress')

                    j=1
                    for ip in $solr_ips_c
                    do
                        updateARecord $zone_rg $zone "${solr_ss_aliases[$j]}-c" $domain $ip $switch
                        j+=1
                    done

                    # neo4j
                    neo4j_nics_c=$(az vmss nic list --vmss-name $neo4j_ss_c --resource-group $rg_c)
                    neo4j_ips_c=$(echo $neo4j_nics_c | jq -r '.[].ipConfigurations[].privateIpAddress')

                    j=1
                    for ip in $neo4j_ips_c
                    do
                        updateARecord $zone_rg $zone "${neo4j_ss_aliases[$j]}-c" $domain $ip $switch
                        j+=1
                    done

                    # karaf
                    karaf_nics_c=$(az vmss nic list --vmss-name $karaf_ss_c --resource-group $rg_c)
                    karaf_ips_c=$(echo $karaf_nics_c | jq -r '.[].ipConfigurations[].privateIpAddress')

                    j=1
                    for ip in $karaf_ips_c
                    do
                        updateARecord $zone_rg $zone "${karaf_ss_aliases[$j]}-c" $domain $ip $switch
                        j+=1
                    done 
                ;;
        esac
        ;;
    app4)
        case $shortenv in
            d | s)
                # vm
                app4_ip_n=$(az vm list-ip-addresses -g $rg_n -n $app4_n | jq -r '.[].virtualMachine.network.privateIpAddresses[]')
                updateARecord $zone_rg $zone "$app2_batch_alias-n" $domain $app4_ip_n $switch
                ;;
            u | r | p)
                ## North ##
                    app4_ip_n=$(az vm list-ip-addresses -g $rg_n -n $app4_n | jq -r '.[].virtualMachine.network.privateIpAddresses[]')
                    updateARecord $zone_rg $zone "$app2_batch_alias-n" $domain $app4_ip_n $switch

                ## Central ##
                    app4_ip_c=$(az vm list-ip-addresses -g $rg_c -n $app4_c | jq -r '.[].virtualMachine.network.privateIpAddresses[]')
                    updateARecord $zone_rg $zone "$app2_batch_alias-n" $domain $app4_ip_c $switch                
                ;;
        esac
        ;;
esac
