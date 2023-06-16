#!/bin/bash
action=$1
ENV=$2

function usage() {
    echo "usage :"
    echo "  helm/app1/setup.sh ACTION ENV"
    echo ""
    echo "example :"
    echo "  helm/app1/setup.sh upgrade dev"
    echo ""
    echo "available actions list :"
    echo "  diff-upgrade  -- executes a diff and shows what is to be applied in case of upgrade"
    echo "  upgrade  -- upgrades the helm chart"
    echo ""
    echo "available environments list :"
    echo "  dev"
    echo "  test"
    echo "  prd"
}

# check kubectl context
function contextCheck () {
    currentContext=$(kubectl config current-context)
    if [[ -z "$currentContext" ]]; then
        echo "can't find context, please ensure right context is set"
    elif [[ "$currentContext" == apps* ]] && [[ $ENV != "prd" ]]; then
        echo "wrong env/context combination: context is devops and env different form prd"
        echo "please set env to prd or change context"
        exit 1
    
    elif [[ "$currentContext" == apps* ]]; then
        if [[ $ENV != "dev" ]] && [[ $ENV != "test" ]]; then
            echo "wrong env/context combination: context is apps and env different form dev or test"
            echo "please set env to dev or test or change context"
            exit 1
        fi
    fi
}



if [[ $action == "upgrade" ]]; then
    contextCheck
    if [[ $ENV == 'dev' ]]; then
        # dev
        # install/upgrade helm/app1
        helm secrets upgrade app1-dev helm/app1/ -n app1-dev --install --create-namespace -f helm/app1/values-dev.yaml 
    elif [[ $ENV == 'test' ]]; then
        # test
        # install/upgrade helm/app1
        helm secrets upgrade app1-test helm/app1/ -n app1-test --install --create-namespace -f helm/app1/values-test.yaml 
    elif [[ $ENV == 'prd' ]]; then
        # prd
        # install/upgrade helm/app1
        helm secrets upgrade app1 helm/app1/ -n app1 --install --create-namespace -f helm/app1/values-prd.yaml 
    else
        echo "no valid env specified"
    fi
    # also upgrade CRDs following the documentation :
    # https://github.com/prometheus-community/helm-charts/tree/main/charts/helm/app1#upgrading-an-existing-release-to-a-new-major-version
elif [[ $action == "diff-upgrade" ]]; then
    contextCheck
    if [[ $ENV == 'dev' ]]; then
        # dev
        # install/upgrade helm/app1
        helm secrets diff upgrade app1-dev helm/app1/ -n app1-dev --install -f helm/app1/values-dev.yaml --detailed-exitcode
        status=$?
        echo $status > helm/app1/helm-diff-exitcode
    elif [[ $ENV == 'test' ]]; then
        # test
        # install/upgrade helm/app1
        helm secrets diff upgrade app1-test helm/app1/ -n app1-test --install -f helm/app1/values-test.yaml --detailed-exitcode
        status=$?
        echo $status > helm/app1/helm-diff-exitcode
    elif [[ $ENV == 'prd' ]]; then
        # prd
        # install/upgrade helm/app1
        helm secrets diff upgrade app1 helm/app1/ -n app1 --install -f helm/app1/values-prd.yaml --detailed-exitcode
        status=$?
        echo $status > helm/app1/helm-diff-exitcode
    else
        echo "no valid env specified"
    fi
elif [[ $action == "help" ]]; then
    usage
else
    echo "no valid action specified"
    usage
fi