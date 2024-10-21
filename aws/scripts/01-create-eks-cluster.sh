#!/bin/bash

# For more information, see https://aws.amazon.com/it/blogs/containers/protecting-your-amazon-eks-web-apps-with-aws-waf/

# Load environment variables
source ./00-variables.sh

# Check if the cluster already exists
EXISTING_CLUSTER=$(eksctl get cluster -o json | jq -r ".[].Name" | grep -E "^${WAF_EKS_CLUSTER_NAME}$")

if [ -n "$EXISTING_CLUSTER" ]; then
  echo "Cluster [$WAF_EKS_CLUSTER_NAME] already exists. Skipping cluster creation."
else
  echo "Cluster [$WAF_EKS_CLUSTER_NAME] does not exist. Creating a new cluster..."

  # Create EKS cluster
  eksctl create cluster \
    --name $WAF_EKS_CLUSTER_NAME \
    --region $WAF_AWS_REGION \
    --managed \
    --nodegroup-name default \
    --ssh-access=true \
    --nodes-min 3 \
    --nodes-max 5 \
    --node-type t3.medium \
    --node-labels "env=dev" \
    --tags "env=dev" \
    --with-oidc \
    --zones $WAF_AWS_REGION"a,"$WAF_AWS_REGION"b,"$WAF_AWS_REGION"c" \
    --asg-access \
    --alb-ingress-access=true

  # Check if the kubectl config already exists for the cluster
  EXISTING_CONFIG=$(kubectl config get-contexts -o name | grep -E "^$WAF_EKS_CLUSTER_NAME$")

  if [ -n "$EXISTING_CONFIG" ]; then
    echo "Kubectl config for cluster [$WAF_EKS_CLUSTER_NAME] already exists. Removing existing config..."

    # Remove the existing kubectl config
    kubectl config delete-context "$WAF_EKS_CLUSTER_NAME"
    kubectl config delete-cluster "$WAF_EKS_CLUSTER_NAME"
  fi

  # Update the kubectl config for the cluster
  aws eks update-kubeconfig --name "$WAF_EKS_CLUSTER_NAME" --alias "$WAF_EKS_CLUSTER_NAME"
fi
