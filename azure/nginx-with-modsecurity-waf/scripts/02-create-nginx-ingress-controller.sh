#!/bin/bash

# Variables
source ./00-variables.sh

# Check if the NGINX ingress controller Helm chart is already installed
result=$(helm list -n $NGINX_NAMESPACE | grep $NGINX_RELEASE_NAME | awk '{print $1}')

if [[ -n $result ]]; then
  echo "[$NGINX_RELEASE_NAME] NGINX ingress controller release already exists in the [$NGINX_NAMESPACE] namespace"
else
  # Check if the NGINX ingress controller repository is not already added
  result=$(helm repo list | grep $NGINX_REPO_NAME | awk '{print $1}')

  if [[ -n $result ]]; then
    echo "[$NGINX_REPO_NAME] Helm repo already exists"
  else
    # Add the NGINX ingress controller repository
    echo "Adding [$NGINX_REPO_NAME] Helm repo..."
    helm repo add $NGINX_REPO_NAME $NGINX_REPO_URL
  fi

  # Update your local Helm chart repository cache
  echo 'Updating Helm repos...'
  helm repo update

  # Deploy NGINX ingress controller
  echo "Deploying [$NGINX_RELEASE_NAME] NGINX ingress controller to the [$NGINX_NAMESPACE] namespace..."
  helm install $NGINX_RELEASE_NAME $NGINX_REPO_NAME/$nginxChartName \
    --create-namespace \
    --namespace $NGINX_NAMESPACE \
    --set controller.replicaCount=3 \
    --set controller.nodeSelector."kubernetes\.io/os"=linux \
    --set controller.replicaCount=$NGINX_REPLICA_COUNT \
    --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux \
    --set controller.metrics.enabled=true \
    --set controller.metrics.serviceMonitor.enabled=true \
    --set controller.metrics.serviceMonitor.additionalLabels.release="prometheus" \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz \
    --set controller.config.modsecurity-snippet=\
'SecRuleEngine On
SecRequestBodyAccess On
SecAuditLog /dev/stdout
SecAuditLogFormat JSON
SecAuditEngine RelevantOnly
SecRule REMOTE_ADDR "@ipMatch 127.0.0.1" "id:87,phase:1,pass,nolog,ctl:ruleEngine=Off"'
fi

# Get values
helm get values $NGINX_RELEASE_NAME --namespace $NGINX_NAMESPACE
