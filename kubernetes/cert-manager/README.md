### Setup cert-manager ###
```
$ kubectl create namespace cert-manager
$ helm repo add jetstack https://charts.jetstack.io
$ helm repo update
$ helm install cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --version v1.9.1  \
    --set installCRDs=true \
    --set extraArgs={"--enable-certificate-owner-ref"="true"}
```

current shd (devops, apps) : kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.9.1/cert-manager.yaml
### Configure cert-manager ###
```
$ kubectl apply -f secret.yaml (add the token first and check the CA)
$ kubectl apply -f clusterissuer-hvault.yaml    
# Check:
$ kubectl get clusterissuers cluster-vault-issuer -n cert-manager -o wide
```
