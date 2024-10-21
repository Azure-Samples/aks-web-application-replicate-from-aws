#!/bin/bash

# Variables
source ./00-variables.sh

# Apply the YAML configuration
kubectl apply -f yelb.yml

# Create chat-ingress
cat ingress.yml |
  yq "(.spec.ingressClassName)|="\""$INGRESS_CLASS_NAME"\" |
  yq "(.spec.rules[0].host)|="\""$SUBDOMAIN.$DNS_ZONE_NAME"\" |
  kubectl apply -f -

# Check the deployed resources within the yelb namespace:
kubectl get all -n yelb
