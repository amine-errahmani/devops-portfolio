### Install and setup nginx ingress controller ###
```
$ helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
$ helm repo update
$ helm upgrade --install --namespace ingress-basic --create-namespace nginx-ingress ingress-nginx/ingress-nginx -f ingress/values-custom.yml


