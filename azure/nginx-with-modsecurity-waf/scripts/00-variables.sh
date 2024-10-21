# Azure Subscription and Tenant
RESOURCE_GROUP_NAME="<your-resource-group-name>"
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
SUBSCRIPTION_NAME=$(az account show --query name --output tsv)
TENANT_ID=$(az account show --query tenantId --output tsv)
DNS_ZONE_NAME="<your-azure-dns-name-eg-contoso-com>"
DNS_ZONE_RESOURCE_GROUP_NAME="<your-azure-dns-resource-group-name>"
DNS_ZONE_SUBSCRIPTION_ID='<your-azure-dns-subscription-id>'
SUBDOMAIN="<your-yelb-application-subdomain>"
URL="https://$SUBDOMAIN.$DNS_ZONE_NAME"

# NGINX Ingress Controller installed via Helm
NGINX_NAMESPACE="ingress-basic"
NGINX_REPO_NAME="ingress-nginx"
NGINX_REPO_URL="https://kubernetes.github.io/ingress-nginx"
NGINX_CHART_NAME="ingress-nginx"
NGINX_RELEASE_NAME="ingress-nginx"
NGINX_REPLICA_COUNT=3

# NGINX Ingress Controller installed via AKS application routing add-on
WEB_APP_ROUTING_NAMESPACE="app-routing-system"
WEB_APP_ROUTING_SERVICE_NAME="nginx"

# Certificate Manager
CM_NAMESPACE="cert-manager"
CM_REPO_NAME="jetstack"
CM_REPO_URL="https://charts.jetstack.io"
CM_CHART_NAME="cert-manager"
CM_RELEASE_NAME="cert-manager"

# Cluster Issuer
EMAIL="<your-email-adddress>"
CLUSTER_ISSUER_NAMES=("letsencrypt-nginx" "letsencrypt-webapprouting")
CLUSTER_ISSUER_TEMPLATES=("cluster-issuer-nginx.yml" "cluster-issuer-webapprouting.yml")

# Specify the ingress class name for the ingress controller.
# - nginx: unmanaged NGINX ingress controller installed vuia Helm
# - webapprouting.kubernetes.azure.com: managed NGINX ingress controller installed via AKS application routing add-on
INGRESS_CLASS_NAME="nginx"

if [[ $INGRESS_CLASS_NAME == "nginx" ]]; then
  # Specify the name of the ingress objects.
  INGRESS_NAME="chat-ingress-nginx"

  # Specify the cluster issuer name for the ingress controller.
  CLUSTER_ISSUER="letsencrypt-nginx"

  # Specify the name of the secret that contains the TLS certificate for the ingress controller.
  INGRESS_SECRET_NAME="chat-tls-secret-nginx"
else
  # Specify the name of the ingress objects.
  INGRESS_NAME="chat-ingress-webapprouting"

  # Specify the cluster issuer name for the ingress controller.
  CLUSTER_ISSUER="letsencrypt-webapprouting"

  # Specify the name of the secret that contains the TLS certificate for the ingress controller.
  INGRESS_SECRET_NAME="chat-tls-secret-webapprouting"
fi