#!/bin/bash

# List all stacks
aws cloudformation list-stacks

# List all EKS clusters
aws eks list-clusters

# List all login profiles
aws configure list

# Refresh sso token
aws sso login --profile SSOAdminAccess-941377123301