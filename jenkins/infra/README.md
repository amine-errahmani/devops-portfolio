# Install Jenkins in Kubernetes Cluster

## Install Jenkins

```
$ helm repo add jenkinsci https://charts.jenkins.io
$ helm repo update
$ helm search repo jenkinsci
$ helm install jenkins -n jenkins -f jenkins-values.yaml jenkinsci/jenkins --version <version from above command>

```


### Upgrade
```
$ helm upgrade  jenkins -n jenkins -f jenkins-values.yaml jenkinsci/jenkins --version 3.9.1 
$ helm list
```

### Remove Jenkins
```
$ helm uninstall jenkins -n jenkins
```
### Migrate Jobs 

### Migrate Credentials

### Troubleshooting
```
$ kubectl logs jenkins-0 -c init?

```
