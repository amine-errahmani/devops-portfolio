#!/bin/bash
action=$1
ENV=$2
DB=$3

function usage() {
    echo "usage :"
    echo " scripts/oracledb-exporter.sh ACTION ENV DB"
    echo ""
    echo "example :"
    echo " scripts/oracledb-exporter.sh upgrade dev db2"
    echo ""
    echo "available actions list :"
    echo "  diff-upgrade  -- executes a diff and shows what is to be applied in case of upgrade"
    echo "  upgrade  -- upgrades the helm chart"
    echo ""
    echo "available environments list :"
    echo "  dev"
    echo "  prod"
    echo ""
    echo "available DB list :"
    echo "  db1"
    echo "  db2"
    echo "  db3"
    echo "  db4"
}

# check kubectl context
function contextCheck () {
    currentContext=$(kubectl config current-context | tr '[:upper:]' '[:lower:]')
    if [[ -z "$currentContext" ]]; then
        echo "can't find context, please ensure right context is set"
    elif [[ "$currentContext" == devops* ]] && [[ $ENV != "prod" ]]; then
        echo "wrong env/context combination: context is devops and env different form prod"
        echo "please set env to prod or change context"
        exit 1
    elif [[ "$currentContext" == devops* ]] && [[ $ENV != "dev" ]]; then
        echo "wrong env/context combination: context is devops and env different form dev"
        echo "please set env to dev or change context"
        exit 1
    elif [[ "$currentContext" != devops* ]] && [[ "$currentContext" != devops* ]]; then
        echo "current context is $currentContext"
        echo "wrong context: context should either be devops or devops"
        echo "please change context"
        exit 1
    fi
}


case $action in

    "diff-upgrade")
        contextCheck

        helm diff upgrade oracledb-exporter-${DB} helm/oracledb-exporter/ -n monitoring-stack --install -f helm/oracledb-exporter/values_${DB}.yaml --detailed-exitcode -C 10
        status=$?
        echo $status > helm/oracledb-exporter/helm-diff-exitcode
        ;;

    "upgrade")
        contextCheck

        helm upgrade oracledb-exporter-${DB} helm/oracledb-exporter/ -n monitoring-stack --install -f helm/oracledb-exporter/values_${DB}.yaml
        ;;

    "help")
       usage
       ;;
       
    *)
        echo "no valid action specified"
        usage
        ;;
esac
