#!/bin/bash

# Variables
source ./00-variables.sh

# Check if namespace exists in the cluster
result=$(kubectl get namespace -o jsonpath="{.items[?(@.metadata.name=='$NAMESPACE')].metadata.name}")

if [[ -n $result ]]; then
  echo "$NAMESPACE namespace already exists in the cluster"
else
  echo "$NAMESPACE namespace does not exist in the cluster"
  echo "creating $NAMESPACE namespace in the cluster..."
  kubectl create namespace $NAMESPACE
fi

# Create the Secret Provider Class object
echo "Creating the secret provider class object..."
cat <<EOF | kubectl apply -f -
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  namespace: $NAMESPACE
  name: yelb
spec:
  provider: azure
  secretObjects:
    - secretName: $TLS_SECRET_NAME
      type: kubernetes.io/tls
      data: 
        - objectName: $KEY_VAULT_CERTIFICATE_NAME
          key: tls.key
        - objectName: $KEY_VAULT_CERTIFICATE_NAME
          key: tls.crt
  parameters:
    usePodIdentity: "false"
    useVMManagedIdentity: "true"
    userAssignedIdentityID: $KEY_VAULT_SECRET_PROVIDER_IDENTITY_CLIENT_ID
    keyvaultName: $KEY_VAULT_NAME
    objects: |
      array:
        - |
          objectName: $KEY_VAULT_CERTIFICATE_NAME
          objectType: secret
    tenantId: $TENANT_ID
EOF

# Apply the YAML configuration
kubectl apply -f yelb.yml

echo "waiting for secret $TLS_SECRET_NAME in namespace $namespace..."

while true; do
  if kubectl get secret -n $NAMESPACE $TLS_SECRET_NAME >/dev/null 2>&1; then
    echo "secret $TLS_SECRET_NAME found!"
    break
  else
    printf "."
    sleep 3
  fi
done

# Create chat-ingress
cat ingress.yml |
  yq "(.spec.ingressClassName)|="\""$INGRESS_CLASS_NAME"\" |
  yq "(.spec.tls[0].hosts[0])|="\""$SUBDOMAIN.$DNS_ZONE_NAME"\" |
  yq "(.spec.tls[0].secretName)|="\""$TLS_SECRET_NAME"\" |
  yq "(.spec.rules[0].host)|="\""$SUBDOMAIN.$DNS_ZONE_NAME"\" |
  kubectl apply -f -

# Check the deployed resources within the yelb namespace:
kubectl get all -n yelb
