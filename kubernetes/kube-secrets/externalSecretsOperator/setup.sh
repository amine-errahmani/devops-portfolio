helm repo add external-secrets https://charts.external-secrets.io

helm upgrade --install external-secrets external-secrets/external-secrets -n external-secrets --create-namespace --set installCRDs=true --set certController.securityContext.capabilities.drop={NET_RAW} --set securityContext.capabilities.drop={NET_RAW} --set webhook.securityContext.capabilities.drop={NET_RAW}


