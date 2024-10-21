#/bin/bash

# Variables
source ./00-variables.sh

# Use a for loop to tag and push the local docker images to the Azure Container Registry
for INDEX in ${!CLUSTER_ISSUER_NAMES[@]}; do
  CLUSTER_ISSUER_NAME=${CLUSTER_ISSUER_NAMES[$INDEX]}

  # Check if the cluster issuer already exists
  RESULT=$(kubectl get clusterissuer -o jsonpath='{.items[?(@.metadata.name=="'"$CLUSTER_ISSUER_NAME"'")].metadata.name}')

  if [[ -n $RESULT ]]; then
    echo "[$CLUSTER_ISSUER_NAME] cluster issuer already exists"
    continue
  else
    # Create the cluster issuer
    echo "[$CLUSTER_ISSUER_NAME] cluster issuer does not exist"
    echo "Creating [$CLUSTER_ISSUER_NAME] cluster issuer..."

    TEMPLATE=${CLUSTER_ISSUER_TEMPLATES[$INDEX]}
    cat $TEMPLATE |
      yq "(.spec.acme.email)|="\""$EMAIL"\" |
      kubectl apply -f -
  fi
done
