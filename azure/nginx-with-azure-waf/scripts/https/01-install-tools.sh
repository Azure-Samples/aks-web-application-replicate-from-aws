#!/bin/bash

# Variables
source ./00-variables.sh

# Install jq if not installed
path=$(which jq)

if [[ -z $path ]]; then
  echo 'Installing jq...'
  sudo apt install -y jq
fi

# Install yq if not installed
path=$(which yq)

if [[ -z $path ]]; then
  echo 'Installing wq...'
  sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq
  sudo chmod +x /usr/bin/yq
fi
