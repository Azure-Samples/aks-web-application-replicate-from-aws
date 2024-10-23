# Azure Resources
RESOURCE_GROUP_NAME="<your-resource-group-name>"
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
SUBSCRIPTION_NAME=$(az account show --query name --output tsv)
TENANT_ID=$(az account show --query tenantId --output tsv)
AKS_CLUSTER_NAME="<your-aks-group-name>"
AGW_NAME="<your-application-gateway-name>"
AGW_PUBLIC_IP_NAME="<your-application-gateway-public-ip-name>"
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

# Specify the ingress class name for the ingress controller.
# - nginx: unmanaged NGINX ingress controller installed via Helm
# - webapprouting.kubernetes.azure.com: managed NGINX ingress controller installed via AKS application routing add-on
INGRESS_CLASS_NAME="webapprouting.kubernetes.azure.com"

# Subdomain of the Yelb UI service
SUBDOMAIN="<your-yelb-application-subdomain>"

# URL of the Yelb UI service
URL="https://$SUBDOMAIN.$DNS_ZONE_NAME"

# Secret Provider Class
KEY_VAULT_NAME="<key-vault-name>"
KEY_VAULT_CERTIFICATE_NAME="<key-vault-certificate-name>"
KEY_VAULT_SECRET_PROVIDER_IDENTITY_CLIENT_ID="16639445-6a46-4f62-90b0-2f1de3f779e7"
TLS_SECRET_NAME="yelb-tls-secret"
NAMESPACE="yelb"