#!/bin/bash
action=$1
ENV=$2

function usage() {
    echo "usage :"
    echo "  scripts/kube-prometheus-stack.sh ACTION ENV"
    echo ""
    echo "example :"
    echo "  scripts/kube-prometheus-stack.sh upgrade dev"
    echo ""
    echo "available actions list :"
    echo "  diff-upgrade  -- executes a diff and shows what is to be applied in case of upgrade"
    echo "  upgrade  -- upgrades the helm chart"
    echo ""
    echo "available environments list :"
    echo "  dev"
    echo "  prod"
    echo "  apps"
    echo "  apps"
    echo "  apps-dr"
}

# check kubectl context
function contextCheck () {
    currentContext=$(kubectl config current-context | tr '[:upper:]' '[:lower:]')
    if [[ -z "$currentContext" ]]; then
        echo "can't find context, please ensure right context is set"
    elif [[ "$currentContext" == devops ]] && [[ $ENV != "prod" ]]; then
        echo "wrong env/context combination: context is devops and env different form prod"
        echo "please set env to prod or change context"
        exit 1
    elif [[ "$currentContext" == devops ]] && [[ $ENV != "dev" ]]; then
        echo "wrong env/context combination: context is devops and env different form dev"
        echo "please set env to dev or change context"
        exit 1
    elif [[ "$currentContext" == apps ]] && [[ $ENV != "apps" ]]; then
        echo "wrong env/context combination: context is apps and env different form apps"
        echo "please set env to dev or change context"
        exit 1
    elif [[ "$currentContext" == apps ]] && [[ $ENV != "apps" ]]; then
        echo "wrong env/context combination: context is apps and env different form apps-north"
        echo "please set env to dev or change context"
        exit 1
    elif [[ "$currentContext" == apps-dr ]] && [[ $ENV != "apps-dr" ]]; then
        echo "wrong env/context combination: context is apps and env different form apps-central"
        echo "please set env to dev or change context"
        exit 1
    fi
}

case $action in

    "diff-upgrade")
        contextCheck
        case $ENV in
            'dev')
                # dev
                # install/upgrade kube-prometheus-stack
                helm secrets diff upgrade monitoring-stack helm/kube-prometheus-stack/ -n monitoring-stack --install -f helm/kube-prometheus-stack/values_devops.yaml -f helm/kube-prometheus-stack/values_alerts.yaml --detailed-exitcode -C 10
                status=$?
                echo $status > helm/kube-prometheus-stack/helm-diff-exitcode
                ;;
            
            'prod')
                # prod
                # install/upgrade kube-prometheus-stack
                helm secrets diff upgrade monitoring-stack helm/kube-prometheus-stack/ -n monitoring-stack --install -f helm/kube-prometheus-stack/values_shp_devops.yaml -f helm/kube-prometheus-stack/values_alerts.yaml --detailed-exitcode -C 10
                status=$?
                echo $status > helm/kube-prometheus-stack/helm-diff-exitcode
                ;;

            'apps')
                # apps
                # install/upgrade kube-prometheus-stack
                helm secrets diff upgrade monitoring-stack helm/kube-prometheus-stack/ -n monitoring-stack --install -f helm/kube-prometheus-stack/values_dev_apps.yaml -f helm/kube-prometheus-stack/values_alerts.yaml --detailed-exitcode -C 10
                status=$?
                echo $status > helm/kube-prometheus-stack/helm-diff-exitcode
                ;;

            'apps')
                # apps-n
                # install/upgrade kube-prometheus-stack
                helm secrets diff upgrade monitoring-stack helm/kube-prometheus-stack/ -n monitoring-stack --install -f helm/kube-prometheus-stack/apps_values_prod_n.yaml -f helm/kube-prometheus-stack/values_alerts.yaml --detailed-exitcode -C 10
                status=$?
                echo $status > helm/kube-prometheus-stack/helm-diff-exitcode
                ;;

            'apps-dr')
                # apps-c
                # install/upgrade kube-prometheus-stack
                helm secrets diff upgrade monitoring-stack helm/kube-prometheus-stack/ -n monitoring-stack --install -f helm/kube-prometheus-stack/apps_values_prod_c.yaml -f helm/kube-prometheus-stack/values_alerts.yaml --detailed-exitcode -C 10
                status=$?
                echo $status > helm/kube-prometheus-stack/helm-diff-exitcode
                ;;
            
            *)
                echo "no valid env specified"
                ;;
        esac
        ;;

    "upgrade")
        contextCheck
        case $ENV in
            'dev')
                # dev
                # install/upgrade kube-prometheus-stack
                helm secrets upgrade monitoring-stack helm/kube-prometheus-stack/ -n monitoring-stack --install --create-namespace -f helm/kube-prometheus-stack/values_devops.yaml -f helm/kube-prometheus-stack/values_alerts.yaml
                ;;
            
            'prod')
                # prod
                # install/upgrade kube-prometheus-stack
                helm secrets upgrade monitoring-stack helm/kube-prometheus-stack/ -n monitoring-stack --install --create-namespace -f helm/kube-prometheus-stack/values_shp_devops.yaml -f helm/kube-prometheus-stack/values_alerts.yaml  
                ;;

            'apps')
                # apps
                # install/upgrade kube-prometheus-stack
                helm secrets upgrade monitoring-stack helm/kube-prometheus-stack/ -n monitoring-stack --install --create-namespace -f helm/kube-prometheus-stack/values_dev_apps.yaml -f helm/kube-prometheus-stack/values_alerts.yaml
                ;;

            'apps-n')
                # apps-n
                # install/upgrade kube-prometheus-stack
                helm secrets upgrade monitoring-stack helm/kube-prometheus-stack/ -n monitoring-stack --install --create-namespace -f helm/kube-prometheus-stack/apps_values_prod_n.yaml -f helm/kube-prometheus-stack/values_alerts.yaml
                ;;

            'apps-c')
                # apps-c
                # install/upgrade kube-prometheus-stack
                helm secrets upgrade monitoring-stack helm/kube-prometheus-stack/ -n monitoring-stack --install --create-namespace -f helm/kube-prometheus-stack/apps_values_prod_c.yaml -f helm/kube-prometheus-stack/values_alerts.yaml
                ;;
            
            *)
                echo "no valid env specified"
                ;;
        esac
        # also upgrade CRDs following the documentation :
        # https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack#upgrading-an-existing-release-to-a-new-major-version
        ;;

    "help")
       usage
       ;;
       
    *)
        echo "no valid action specified"
        usage
        ;;
esac
