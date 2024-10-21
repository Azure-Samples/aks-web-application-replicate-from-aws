#!/bin/bash

# Download the Yelb YAML manifest from the official repository
curl -o yelb_initial_deployment.yaml https://raw.githubusercontent.com/aws/aws-app-mesh-examples/main/walkthroughs/eks-getting-started/infrastructure/yelb_initial_deployment.yaml

# Apply the YAML configuration
kubectl apply -f yelb_initial_deployment.yaml

# Check the deployed resources within the yelb namespace:
kubectl get all -n yelb
