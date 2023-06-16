#!/bin/bash
action=$1
ENV=$2

function usage() {
    echo "usage :"
    echo "  scripts/jenkins.sh ACTION ENV"
    echo ""
    echo "example :"
    echo "  scripts/jenkins.sh upgrade dev"
    echo ""
    echo "available actions list :"
    echo "  diff-upgrade  -- executes a diff and shows what is to be applied in case of upgrade"
    echo "  upgrade  -- upgrades the helm chart"
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

contextCheck

if [[ $action == "upgrade" ]]; then
    if [[ $ENV == 'dev' ]]; then
        ## install/upgrade jenkins chart
        helm secrets upgrade --install jenkins jenkins/jenkins -f jks/jks-values.yaml --namespace jenkins --create-namespace
    elif [[ $ENV == 'prod' ]]; then
        helm secrets upgrade --install jenkins jenkins/jenkins -f devops/devops-jenkins.yaml --namespace jenkins --create-namespace
    else
        echo "no valid env specified"
    fi
elif [[ $action == "diff-upgrade" ]]; then
    if [[ $ENV == 'dev' ]]; then
        ## install/upgrade jenkins chart
        helm secrets diff upgrade --install jenkins jenkins/jenkins -f jks/jks-values.yaml --namespace jenkins --detailed-exitcode -C 10
        status=$?
        echo $status > helm-diff-exitcode
    elif [[ $ENV == 'prod' ]]; then
        helm secrets diff upgrade --install jenkins jenkins/jenkins -f devops/devops-jenkins.yaml --namespace jenkins --detailed-exitcode -C 10
        status=$?
        echo $status > helm-diff-exitcode
    else
        echo "no valid env specified"
    fi
elif [[ $action == "help" ]]; then
    usage
else
    echo "no valid action specified"
    usage
fi