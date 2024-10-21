#!/bin/bash

# For more information, see https://aws.amazon.com/it/blogs/containers/protecting-your-amazon-eks-web-apps-with-aws-waf/

# Load environment variables
source ./00-variables.sh

# The AWS Load Balancer Controller is a Kubernetes controller that runs in your EKS cluster and handles the configuration of the Network Load Balancers and Application Load Balancers on your behalf.
# It allows you to configure Load Balancers declaratively in the same manner as you handle the configuration of your application.

# Get the VPC ID
WAF_VPC_ID=$(aws eks describe-cluster \
  --name $WAF_EKS_CLUSTER_NAME \
  --region $WAF_AWS_REGION \
  --query 'cluster.resourcesVpcConfig.vpcId' \
  --output text)

# Install the AWS Load Balancer Controller by running these commands:
## Associate OIDC provider
eksctl utils associate-iam-oidc-provider \
  --cluster $WAF_EKS_CLUSTER_NAME \
  --region $WAF_AWS_REGION \
  --approve

# Download the IAM policy document
curl -o iam-policy.json https://raw.githubusercontent.com/aws-samples/containers-blog-maelstrom/main/eks-waf-blog/iam-policy.json

# Create an IAM policy
WAF_LBC_IAM_POLICY=$(aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy-WAFDEMO \
  --policy-document file://iam-policy.json)

# Get IAM Policy ARN
WAF_LBC_IAM_POLICY_ARN=$(aws iam list-policies \
  --query "Policies[?PolicyName=='AWSLoadBalancerControllerIAMPolicy-WAFDEMO'].Arn" \
  --output text)

# Create a service account
eksctl create iamserviceaccount \
  --cluster=$WAF_EKS_CLUSTER_NAME \
  --region $WAF_AWS_REGION \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --override-existing-serviceaccounts \
  --attach-policy-arn=${WAF_LBC_IAM_POLICY_ARN} \
  --approve

# Add the helm repo and install the AWS Load Balancer Controller
helm repo add eks https://aws.github.io/eks-charts && helm repo update

# Update the Helm repo
helm repo update

# Install the AWS Load Balancer Controller via Helm
helm install aws-load-balancer-controller \
  eks/aws-load-balancer-controller \
  --namespace kube-system \
  --set clusterName=$WAF_EKS_CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set vpcId=$WAF_VPC_ID \
  --set region=$WAF_AWS_REGION

# Verify that the controller is installed
kubectl get deployment -n kube-system aws-load-balancer-controller