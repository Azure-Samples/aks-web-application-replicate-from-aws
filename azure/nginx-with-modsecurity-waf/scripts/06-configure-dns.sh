#!/bin/bash

# Variables
source ./00-variables.sh

# Choose the ingress controller to use
if [[ $INGRESS_CLASS_NAME == "nginx" ]]; then
    INGRESS_NAMESPACE=$NGINX_NAMESPACE
    INGRESS_SERVICE_NAME="${NGINX_RELEASE_NAME}-controller"
else
    INGRESS_NAMESPACE=$WEB_APP_ROUTING_NAMESPACE
    INGRESS_SERVICE_NAME=$WEB_APP_ROUTING_SERVICE_NAME
fi

# Retrieve the public IP address of the NGINX ingress controller
echo "Retrieving the external IP address of the [$INGRESS_CLASS_NAME] NGINX ingress controller..."
PUBLIC_IP_ADDRESS=$(kubectl get service -o json -n $INGRESS_NAMESPACE |
    jq -r '.items[] | 
    select(.spec.type == "LoadBalancer") |
    .status.loadBalancer.ingress[0].ip')

if [ -n "$PUBLIC_IP_ADDRESS" ]; then
    echo "[$PUBLIC_IP_ADDRESS] external IP address of the [$INGRESS_CLASS_NAME] NGINX ingress controller successfully retrieved"
else
    echo "Failed to retrieve the external IP address of the [$INGRESS_CLASS_NAME] NGINX ingress controller"
    exit
fi

# Check if an A record for todolist subdomain exists in the DNS Zone
echo "Retrieving the A record for the [$SUBDOMAIN] subdomain from the [$DNS_ZONE_NAME] DNS zone..."
IPV4_ADDRESS=$(az network dns record-set a list \
    --zone-name $DNS_ZONE_NAME \
    --resource-group $DNS_ZONE_RESOURCE_GROUP_NAME \
    --subscription $DNS_ZONE_SUBSCRIPTION_ID \
    --query "[?name=='$SUBDOMAIN'].ARecords[].IPV4_ADDRESS" \
    --output tsv \
    --only-show-errors)

if [[ -n $IPV4_ADDRESS ]]; then
    echo "An A record already exists in [$DNS_ZONE_NAME] DNS zone for the [$SUBDOMAIN] subdomain with [$IPV4_ADDRESS] IP address"

    if [[ $IPV4_ADDRESS == $PUBLIC_IP_ADDRESS ]]; then
        echo "The [$IPV4_ADDRESS] ip address of the existing A record is equal to the ip address of the ingress"
        echo "No additional step is required"
        continue
    else
        echo "The [$IPV4_ADDRESS] ip address of the existing A record is different than the ip address of the ingress"
    fi
    # Retrieving name of the record set relative to the zone
    echo "Retrieving the name of the record set relative to the [$DNS_ZONE_NAME] zone..."

    RECORDSET_NAME=$(az network dns record-set a list \
        --zone-name $DNS_ZONE_NAME \
        --resource-group $DNS_ZONE_RESOURCE_GROUP_NAME \
        --subscription $DNS_ZONE_SUBSCRIPTION_ID \
        --query "[?name=='$SUBDOMAIN'].name" \
        --output tsv \
        --only-show-errors 2>/dev/null)

    if [[ -n $RECORDSET_NAME ]]; then
        echo "[$RECORDSET_NAME] record set name successfully retrieved"
    else
        echo "Failed to retrieve the name of the record set relative to the [$DNS_ZONE_NAME] zone"
        exit
    fi

    # Remove the A record
    echo "Removing the A record from the record set relative to the [$DNS_ZONE_NAME] zone..."

    az network dns record-set a remove-record \
        --ipv4-address $IPV4_ADDRESS \
        --record-set-name $RECORDSET_NAME \
        --zone-name $DNS_ZONE_NAME \
        --resource-group $DNS_ZONE_RESOURCE_GROUP_NAME \
        --subscription $DNS_ZONE_SUBSCRIPTION_ID \
        --only-show-errors 1>/dev/null

    if [[ $? == 0 ]]; then
        echo "[$IPV4_ADDRESS] ip address successfully removed from the [$RECORDSET_NAME] record set"
    else
        echo "Failed to remove the [$IPV4_ADDRESS] ip address from the [$RECORDSET_NAME] record set"
        exit
    fi
fi

# Create the A record
echo "Creating an A record in [$DNS_ZONE_NAME] DNS zone for the [$SUBDOMAIN] subdomain with [$PUBLIC_IP_ADDRESS] IP address..."
az network dns record-set a add-record \
    --zone-name $DNS_ZONE_NAME \
    --resource-group $DNS_ZONE_RESOURCE_GROUP_NAME \
    --subscription $DNS_ZONE_SUBSCRIPTION_ID \
    --record-set-name $SUBDOMAIN \
    --ipv4-address $PUBLIC_IP_ADDRESS \
    --only-show-errors 1>/dev/null

if [[ $? == 0 ]]; then
    echo "A record for the [$SUBDOMAIN] subdomain with [$PUBLIC_IP_ADDRESS] IP address successfully created in [$DNS_ZONE_NAME] DNS zone"
else
    echo "Failed to create an A record for the $SUBDOMAIN subdomain with [$PUBLIC_IP_ADDRESS] IP address in [$DNS_ZONE_NAME] DNS zone"
fi
