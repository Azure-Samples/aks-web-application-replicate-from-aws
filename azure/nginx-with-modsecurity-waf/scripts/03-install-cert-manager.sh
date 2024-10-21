#/bin/bash

# Variables
source ./00-variables.sh

# Check if the certificate manager Helm chart is already installed
result=$(helm list -n $CM_NAMESPACE | grep $CM_RELEASE_NAME | awk '{print $1}')

if [[ -n $result ]]; then
  echo "[$CM_RELEASE_NAME] certificate manager release already exists in the [$CM_NAMESPACE] namespace"
else
  # Check if the certificate manager repository is not already added
  result=$(helm repo list | grep $CM_REPO_NAME | awk '{print $1}')

  if [[ -n $result ]]; then
    echo "[$CM_REPO_NAME] Helm repo already exists"
  else
    # Add the certificate manager repository
    echo "Adding [$CM_REPO_NAME] Helm repo..."
    helm repo add $CM_REPO_NAME $CM_REPO_URL
  fi

  # Update your local Helm chart repository cache
  echo 'Updating Helm repos...'
  helm repo update

  # Install the cert-manager Helm chart
  echo "Deploying [$CM_RELEASE_NAME] cert-manager to the $CM_NAMESPACE namespace..."
  helm install $CM_RELEASE_NAME $CM_REPO_NAME/$cmChartName \
    --create-namespace \
    --namespace $CM_NAMESPACE \
    --set installCRDs=true \
    --set nodeSelector."kubernetes\.io/os"=linux
fi