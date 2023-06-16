# GitHub Self hosted runner

A self-hosted runner is a system that you deploy and manage to execute jobs from GitHub Actions on GitHub.com [1]. We use self hosted runner so we are able to access resources in our Azure VNet that are otherwise not accessible from the Internet. This will help us move away from Jenkins in the future.

# Installing self hosted runner in Azure Kubernetes Service

## Pre-reqs (Client)
- kubectl CLI
- kubectx & kubens
- helm CLI

## Pre-reqs (Cluster)
- kubernetes cluster
- cert-manager

## Steps 2 - Auto Installion

Use the deploy.sh script as follows:

```
$ deploy.sh context gh_org
```

## Steps 3a Manual Installation - Install Runner CRDs
```
$ kubectx 'context'
$ kubectl create namespace 'actions-runner-system'
$ kubens 'actions-runner-system'

$ helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller

# Install chart
$ export GITHUB_ORG_ACCESS_TOKEN=ghp_EXAMPLE..... # Needs the PAT to be created by an Org Owner
$ helm install -f custom-values.yaml --set authSecret.github_token=$GITHUB_ORG_ACCESS_TOKEN --set securityContext.capabilities.drop={NET_RAW} --wait --namespace actions-runner-system actions-runner-controller actions-runner-controller/actions-runner-controller

# Verify installation
$ kubectl --namespace actions-runner-system get all

```
## Steps 3b Manual Installation - Install Hosted Runner
```
$ kubectl create namespace self-hosted-runners
$ GH_ORG=gh_org
$ sed -i "s/REPLACE_WITH_GITHUB_ORG_NAME/$GH_ORG/g" self-hosted-runner-for-org.yaml
$ kubectl --namespace self-hosted-runners apply -f self-hosted-runner-for-org.yaml
# Verify the runner is deployed and is in ready state.
$ kubectl --namespace self-hosted-runners get runner

```
## UnInstall
```
$ kubectl --namespace self-hosted-runners delete -f self-hosted-runner-for-org.yaml 
$ kubectl delete namespace self-hosted-runners
$ helm uninstall --namespace actions-runner-system actions-runner-controller actions-runner-controller/actions-runner-controller
$ kubectl delete namespace actions-runner-system


```

## Troubleshooting

- Check the Secret 'controller-manager' in 'actions-runner-system', shoould be a valid GitHub Token
- 

## References

1. https://docs.github.com/en/actions/hosting-your-own-runners/about-self-hosted-runners
2. https://github.com/actions-runner-controller/actions-runner-controller#organization-runners
3. https://medium.com/geekculture/github-actions-self-hosted-runner-on-kubernetes-55d077520a31
4. https://github.com/actions-runner-controller/actions-runner-controller/issues/84#issuecomment-756971038


to keep runners at 0 : 
https://github.com/actions-runner-controller/actions-runner-controller/blob/master/docs/detailed-docs.md#autoscaling-tofrom-0