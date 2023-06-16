#!/bin/bash
NOW="$(date +'%B %d, %Y')"
RED="\033[1;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
PURPLE="\033[1;35m"
CYAN="\033[1;36m"
WHITE="\033[1;37m"
RESET="\033[0m"

#Vars
module=$1
action=$2


function fail_banner () {
    if [ $status = 1 ]; then
        echo "----------------------------------------------------"
        echo -e "| ${RED} Something went wrong! ${RESET}"
        echo "----------------------------------------------------"
        exit 1
    fi
}

function stage_banner () {
    bmodule=$1
    baction=$2
    IFS='-'
    read -ra ADDR <<< "$baction"
    tfaction=${ADDR[1]}
    tfmodule=${ADDR[2]}
    if [ ! $tfmodule ]; then
        echo "--------------------------------------------"
        echo -e "| ${GREEN} Running terraform ${CYAN}$tfaction${GREEN} on module ${CYAN}$bmodule${GREEN} ... ${RESET}"
        echo "--------------------------------------------"
    else
        echo "---------------------------------------------------"
        echo -e "| ${GREEN} Running terraform ${CYAN}$tfaction${GREEN} on module ${CYAN}$bmodule${GREEN} on component ${CYAN}$tfmodule${GREEN} ... ${RESET}"
        echo "---------------------------------------------------"
    fi
}


if [ $module == "AKS" ] || [ $module == "MAIN" ]; then
    export TF_VAR_MODULE=$module
    export TF_VAR_ENV="env"
    export TF_VAR_CLUSTER="devops"

    echo "----------------------------------------------------"
    echo  "| ${CYAN} Module: $TF_VAR_MODULE ${RESET}"
    echo  "| ${CYAN} Environment: $TF_VAR_ENV ${RESET}"
    echo  "| ${CYAN} Cluster:${RESET} ${GREEN} $TF_VAR_CLUSTER ${RESET}"
    echo "----------------------------------------------------"


    if [ $action = "-init" ]; then
        stage_banner "$module" $action
        rm -rf terraform/$module/.terraform
        terragrunt init --terragrunt-config terraform/$module/terragrunt.hcl --terragrunt-working-dir terraform/$module
        status=$?
        fail_banner
    elif [ $action = "-plan" ]; then    
        stage_banner "$module" $action
        terragrunt plan -var-file=../values/env-devops.tfvars -out="$module-tfplan" -detailed-exitcode --terragrunt-config terraform/$module/terragrunt.hcl --terragrunt-working-dir terraform/$module
        status=$?
        echo $status > terraform/$module/$module-tfplan-exitcode
        fail_banner
    elif [ $action = "-apply" ]; then
        stage_banner "$module" $action
        terragrunt apply "$module-tfplan" --terragrunt-config terraform/$module/terragrunt.hcl --terragrunt-working-dir terraform/$module
        status=$?
        fail_banner
    elif [ $action = "-autoapply" ]; then
        stage_banner "$module" $action
        terragrunt apply -var-file=../values/env-devops.tfvars --terragrunt-config terraform/$module/terragrunt.hcl --terragrunt-working-dir terraform/$module --auto-approve
        status=$?
        fail_banner
    elif [ $action == "-plandestroy" ]; then
        stage_banner "$module" $action
        terragrunt plan -destroy -var-file=../values/env-devops.tfvars -out="$module-tfplan-destroy" -detailed-exitcode --terragrunt-config terraform/$module/terragrunt.hcl --terragrunt-working-dir terraform/$module
        status=$?
        echo $status > terraform/$module/$module-tfplan-exitcode
        fail_banner
    elif [ $action == "-destroy" ]; then
        stage_banner "$module" $action
        terragrunt destroy -var-file=../values/env-devops.tfvars -auto-approve --terragrunt-config terraform/$module/terragrunt.hcl --terragrunt-working-dir terraform/$module
        status=$?
        fail_banner
    fi

else
    echo "----------------------------------------------------"
    echo -e "| ${RED} No Valid Module specified ${RESET}"
    echo "----------------------------------------------------"
    exit 1
fi


