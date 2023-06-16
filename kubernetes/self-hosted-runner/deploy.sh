#!/bin/bash
CONTEXT=$1
GH_ORG=$2

if [ $GITHUB_ORG_ACCESS_TOKEN == ""]; then
  tput setaf 1; echo Please export "GITHUB_ORG_ACCESS_TOKEN" with Org owner priviledges and retry.
  exit 1
fi

if ! [ -x "$(command -v kubectx)" ]; then
  tput setaf 1; echo 'Error: kubectx is not installed. Do a: brew update && brew install kubectx' >&2
  exit 1
fi

if ! [ -x "$(command -v kubens)" ]; then
  tput setaf 1; echo 'Error: kubens is not installed. Do a: brew update && brew install kubens' >&2
  exit 1
fi

if ! [ -x "$(command -v helm)" ]; then
  tput setaf 1; echo 'Error: helm is not installed. Do a: brew update && brew install helm' >&2
  exit 1
fi

set -e

echo Installing Runner CRDs
kubectx $CONTEXT
kubectl create namespace 'actions-runner-system'
kubens 'actions-runner-system'
helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller

echo Install chart
#export GITHUB_ORG_ACCESS_TOKEN=ghp_EXAMPLE..... # Needs the PAT to be created by an Org Owner
helm install -f custom-values.yaml --set authSecret.github_token=$GITHUB_ORG_ACCESS_TOKEN --set securityContext.capabilities.drop={NET_RAW} --wait --namespace actions-runner-system actions-runner-controller actions-runner-controller/actions-runner-controller

echo Verify installation
kubectl --namespace actions-runner-system get all

echo Installing Hosted Runner
kubectl create namespace self-hosted-runners
sed -i "s/REPLACE_WITH_GITHUB_ORG_NAME/$GH_ORG/g" self-hosted-runner-for-org.yaml
kubectl --namespace self-hosted-runners apply -f self-hosted-runner-for-org.yaml

echo Verify the runner is deployed and is in ready state.
kubectl --namespace self-hosted-runners get runner
