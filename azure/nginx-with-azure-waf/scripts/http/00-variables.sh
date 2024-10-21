# Azure Resources
RESOURCE_GROUP_NAME="AnubisRG"
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
SUBSCRIPTION_NAME=$(az account show --query name --output tsv)
TENANT_ID=$(az account show --query tenantId --output tsv)
AKS_CLUSTER_NAME="AnubisAks"
AGW_NAME="AnubisApplicationGateway"
AGW_PUBLIC_IP_NAME="AnubisApplicationGatewayPublicIp"
DNS_ZONE_NAME="<your-azure-dns-name-eg-contoso-com>"
DNS_ZONE_RESOURCE_GROUP_NAME="<your-azure-dns-resource-group-name>"
DNS_ZONE_SUBSCRIPTION_ID='<your-azure-dns-subscription-id>'

# NGINX Ingress Controller installed via Helm
NGINX_NAMESPACE="ingress-basic"
NGINX_REPO_NAME="ingress-nginx"
NGINX_REPO_URL="https://kubernetes.github.io/ingress-nginx"
NGINX_CHART_NAME="ingress-nginx"
NGINX_RELEASE_NAME="ingress-nginx"
NGINX_REPLICA_COUNT=3

# Ingress and DNS
INGRESS_CLASS_NAME="nginx"
SUBDOMAIN="anubisyelb"
URL="https://$SUBDOMAIN.$DNS_ZONE_NAME"
