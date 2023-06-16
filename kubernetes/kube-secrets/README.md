# ESO (External Secrets Operator)

This project holds setup scripts for the external secrets operator and the manifest files for the secret resources :
* setup.sh : to deploy the ESO helm chart
* manifest files to create the various resources :
  * ClusterSecretStore : the manifest to link the cluster to the hashicorp vault cluster (or azure key vault) and make it available for all namespaces in the cluster
  * ClusterExternalSecret : the manifests to define the secret(s) to fetch from the ClusterSecretStore defined above and make them available for all namespaces in the cluster
  * ExternalSecret : the manifests to define the secret(s) to fetch from the ClusterSecretStore defined above and make them available for a specific namespace in the cluster


### REQUIREMENTS
* helm
* kubectl


### SETUP 

* create vault token secret with read access : 
  ``` 
    export VAULT_TOKEN_ESO_READ='xxx'
    kubectl create secret generic external-secrets-vault-read-token --from-literal=vault-token=$VAULT_TOKEN_ESO_READ -n external-secrets
  ```

* install the ESO chart 
  ```
    kube-secrets/externalSecretsOperator/setup.sh
  ```

* create the ClusterSecretStore :
  ```
    kubectl apply -f kube-secrets/clusterSecretStore.yml
  ```

* create a ClusterExternalSecret : (secret created in all selected namaspaces)
  ```
    kubectl apply -f kube-secrets/clusterExternalSecret-jfrog.yml
  ```

* create an ExternalSecret : (namaspaced resource)
  ```
    kubectl apply -f kube-secrets/test-external-secret.yml -n external-secrets 
  ```


### References & Documentation
- https://external-secrets.io/v0.5.9/
- https://external-secrets.io/v0.5.9/guides-common-k8s-secret-types/
- https://external-secrets.io/v0.5.9/provider-hashicorp-vault/
- https://github.com/external-secrets/external-secrets/
- https://www.youtube.com/watch?v=EW25WpErCmA