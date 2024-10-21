#!/bin/bash

# Variables
source ./00-variables.sh

# Apply the YAML configuration
kubectl apply -f yelb.yml

# Create chat-ingress
cat ingress.yml |
  yq "(.metadata.annotations.\"cert-manager.io/cluster-issuer\")|="\""$CLUSTER_ISSUER"\" |
  yq "(.spec.ingressClassName)|="\""$INGRESS_CLASS_NAME"\" |
  yq "(.spec.tls[0].hosts[0])|="\""$SUBDOMAIN.$DNS_ZONE_NAME"\" |
  yq "(.spec.tls[0].secretName)|="\""$INGRESS_SECRET_NAME"\" |
  yq "(.spec.rules[0].host)|="\""$SUBDOMAIN.$DNS_ZONE_NAME"\" |
  kubectl apply -f -

# Check the deployed resources within the yelb namespace:
kubectl get all -n yelb
