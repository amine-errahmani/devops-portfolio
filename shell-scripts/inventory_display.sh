#!/bin/bash

ENV=$1
region=$2
module=$3

inventory="ansible/inventory/current/ips/inventory_${ENV}.ini"

if [[ $ENV && $region ]]; then

    case $module in
        app3)
            if [ $ENV == "prp" ]; then
                if [ $region == 'n' ]; then
                    cat $inventory | grep '\[app3_n\]' -A2
                else
                    echo "region not valid"
                fi
            else
                if [ $region == 'n' ]; then
                    cat $inventory | grep '\[neo4j_servers_n\]' -A3
                    cat $inventory | grep '\[solr_servers_n\]' -A3
                    cat $inventory | grep '\[karaf_servers_n\]' -A4
                elif [ $region == 'c' ]; then
                    cat $inventory | grep '\[neo4j_servers_c\]' -A3
                    cat $inventory | grep '\[solr_servers_c\]' -A3
                    cat $inventory | grep '\[karaf_servers_c\]' -A3
                else
                    echo "region not valid"
                fi
            fi
            ;;
        app2)
            if [ $region == 'n' ]; then
                cat $inventory | grep '\[app2_batch_n\]' -A2
                cat $inventory | grep '\[app2_ss_n\]' -A4
            elif [ $region == 'c' ]; then
                cat $inventory | grep '\[app2_batch_c\]' -A2
                cat $inventory | grep '\[app2_ss_c\]' -A3
            else
                echo "region not valid"
            fi
            ;;
        app1)
            if [ $region == 'n' ]; then
                cat $inventory | grep '\[app1_ss_n\]' -A3
            elif [ $region == 'c' ]; then
                cat $inventory | grep '\[app1_ss_c\]' -A2
            else
                echo "region not valid"
            fi
            ;;
    esac
else
    echo "no ENV or region specified"
    exit 1
fi
