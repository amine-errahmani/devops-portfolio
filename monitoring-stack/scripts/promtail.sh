#!/bin/bash
action=$1
ENV=$2


function usage() {
    echo "usage :"
    echo " scripts/promtail.sh ACTION ENV"
    echo ""
    echo "example :"
    echo " scripts/promtail.sh upgrade dev"
    echo ""
    echo "available actions list :"
    echo "  diff-upgrade  -- executes a diff and shows what is to be applied in case of upgrade"
    echo "  upgrade  -- upgrades the helm chart"
    echo ""
    echo "available environments list :"
    echo "  dev"
    echo "  prod"
    echo "  apps"
    echo "  apps-prod"
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
    elif [[ "$currentContext" == apps* ]] && [[ $ENV != "apps" ]]; then
        echo "wrong env/context combination: context is apps and env different form apps"
        echo "please set env to dev or change context"
        exit 1
    elif [[ "$currentContext" == apps* ]] && [[ $ENV != "apps-prod" ]]; then
        echo "wrong env/context combination: context is apps and env different form apps-north"
        echo "please set env to dev or change context"
        exit 1
    fi
}

# helm repo add grafana https://grafana.github.io/helm-charts
# helm repo update

## https://github.com/grafana/helm-charts/tree/main/charts/promtail

if [[ $action == "upgrade" ]]; then
    contextCheck
    if [[ $ENV == 'dev' ]] || [[ $ENV == 'prod' ]]; then
        ## install/upgrade loki chart
        helm upgrade --install promtail grafana/promtail -f helm/promtail/values.yaml --namespace monitoring-stack
    elif [[ $ENV == 'apps' ]]; then
        helm upgrade --install promtail grafana/promtail -f helm/promtail/values-apps-dev.yaml --namespace monitoring-stack
    elif [[ $ENV == 'apps-prod' ]]; then
        helm upgrade --install promtail grafana/promtail -f helm/promtail/values-apps-prd.yaml --namespace monitoring-stack
    else
        echo "no valid env specified"
    fi
elif [[ $action == "diff-upgrade" ]]; then
    contextCheck
    if [[ $ENV == 'dev' ]] || [[ $ENV == 'prod' ]]; then
        ## install/upgrade loki chart
        helm diff upgrade --install promtail grafana/promtail -f helm/promtail/values.yaml --namespace monitoring-stack --detailed-exitcode -C 10
        status=$?
        echo $status > helm/promtail/helm-diff-exitcode
    elif [[ $ENV == 'apps' ]]; then
        helm diff upgrade --install promtail grafana/promtail -f helm/promtail/values-apps-dev.yaml --namespace monitoring-stack --detailed-exitcode -C 10
        status=$?
        echo $status > helm/promtail/helm-diff-exitcode
    elif [[ $ENV == 'apps-prod' ]]; then
        helm diff upgrade --install promtail grafana/promtail -f helm/promtail/values-apps-prd.yaml --namespace monitoring-stack --detailed-exitcode -C 10
        status=$?
        echo $status > helm/promtail/helm-diff-exitcode
    else
        echo "no valid env specified"
    fi
elif [[ $action == "help" ]]; then
    usage
else
    echo "no valid action specified"
    usage
fi
