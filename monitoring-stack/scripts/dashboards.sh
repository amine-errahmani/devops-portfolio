#!/bin/bash
action=$1
ENV=$2

function usage() {
    echo "usage :"
    echo "  scripts/dashboards.sh ACTION ENV"
    echo ""
    echo "example :"
    echo "  scripts/dashboards.sh upgrade dev"
    echo ""
    echo "available actions list :"
    echo "  diff-dash -- executes a diff and shows what is to be applied in case of upgrade of the dashboards"
    echo "  dash -- upgrades the dashboards"
    echo ""
    echo "available environments list :"
    echo "  dev"
    echo "  prod"
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


# check for uniqueness of dashboard titles and uids
function uniqueDash () {
    # echo "checking dashboard titles for uniqueness:"
    # echo "(if any dashboard titles are listed below, they have a title used elsewhere)"
    titleDiffRes=`diff <(grep "^      \"title\"" -rin custom/dashboards/*/ | cut -d':' -f4 | sort) <(grep "^      \"title\"" -rin custom/dashboards/*/ | cut -d':' -f4 | sort | uniq)` 

    
    
    # check for uniqueness of dashboard uids
    uidDiffRes=`diff <(grep "^      \"uid\"" -rin custom/dashboards/*/ | cut -d':' -f4 | sort) <(grep "^      \"uid\"" -rin custom/dashboards/*/ | cut -d':' -f4 | sort | uniq)`

    

    if [[ ! -z "$titleDiffRes" ]] || [[ ! -z "$uidDiffRes" ]] ; then
        echo "titleDiffRes: $titleDiffRes"
        echo "uidDiffRes: $uidDiffRes"
        echo "Dashboards uids or titles not unique"
        exit 1
    fi
}

case $action in   
    "diff-dash")
        contextCheck

        uniqueDash

        # diff on windows dashboards configmaps
        kubectl apply -f custom/dashboards/windows -n monitoring-stack --dry-run=server | grep -wv unchanged
        # diff on linux dashboards configmaps
        kubectl apply -f custom/dashboards/linux -n monitoring-stack --dry-run=server | grep -wv unchanged
        # diff on application dashboards configmaps
        kubectl apply -f custom/dashboards/application -n monitoring-stack --dry-run=server | grep -wv unchanged
        # diff on database dashboards configmaps
        kubectl apply -f custom/dashboards/database -n monitoring-stack --dry-run=server | grep -wv unchanged
        # diff on alert dashboards configmaps
        kubectl apply -f custom/dashboards/alert -n monitoring-stack --dry-run=server | grep -wv unchanged
        ;;

    "dash")
        contextCheck
        
        uniqueDash

        # create/update windows dashboards configmaps
        kubectl apply -f custom/dashboards/windows -n monitoring-stack | grep -wv unchanged
        # create/update linux dashboards configmaps
        kubectl apply -f custom/dashboards/linux -n monitoring-stack | grep -wv unchanged
        # create/update application dashboards configmaps
        kubectl apply -f custom/dashboards/application -n monitoring-stack | grep -wv unchanged
        # create/update database dashboards configmaps
        kubectl apply -f custom/dashboards/database -n monitoring-stack | grep -wv unchanged
        # create/update alert dashboards configmaps
        kubectl apply -f custom/dashboards/alert -n monitoring-stack | grep -wv unchanged
        ;;

    "help")
       usage
       ;;
       
    *)
        echo "no valid action specified"
        usage
        ;;
esac
