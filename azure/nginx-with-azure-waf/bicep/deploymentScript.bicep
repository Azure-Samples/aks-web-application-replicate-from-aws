// For more information, see https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/deployment-script-bicep
@description('Specifies the name of the deployment script uri.')
param name string = 'BashScript'

@description('Specifies the Azure CLI module version.')
param azCliVersion string = '2.61.0'

@description('Specifies the maximum allowed script execution time specified in ISO 8601 format. Default value is P1D.')
param timeout string = 'PT30M'

@description('Specifies the clean up preference when the script execution gets in a terminal state. Default setting is Always.')
@allowed([
  'Always'
  'OnExpiration'
  'OnSuccess'
])
param cleanupPreference string = 'OnSuccess'

@description('Specifies the interval for which the service retains the script resource after it reaches a terminal state. Resource will be deleted when this duration expires.')
param retentionInterval string = 'P1D'

@description('Specifies the name of the user-assigned managed identity of the deployment script.')
param managedIdentityName string

@description('Specifies the primary script URI.')
param primaryScriptUri string

@description('Specifies the name of the AKS cluster.')
param clusterName string

@description('Specifies the resource group name')
param resourceGroupName string = resourceGroup().name

@description('Specifies the subscription id.')
param subscriptionId string = subscription().subscriptionId

@description('Specifies whether to deploy Prometheus and Grafana to the AKS cluster using a Helm chart.')
param deployPrometheusAndGrafanaViaHelm bool = true

@description('Specifies whether to whether to deploy the Certificate Manager to the AKS cluster using a Helm chart.')
param deployCertificateManagerViaHelm bool = true

@description('Specifies the list of ingress classes for which a cert-manager cluster issuer should be created.')
param ingressClassNames array = ['nginx', 'webapprouting.kubernetes.azure.com']

@description('Specifies the list of the names for the cert-manager cluster issuers.')
param clusterIssuerNames array = ['letsencrypt-nginx', 'letsencrypt-webapprouting']

@description('Specifies whether and how to deploy the NGINX Ingress Controller to the AKS cluster using a Helm chart. Possible values are None, Internal, and External.')
@allowed([
  'None'
  'Internal'
  'External'
])
param deployNginxIngressControllerViaHelm string = 'Internal'

@description('Specifies the email address for the cert-manager cluster issuer.')
param email string = 'admin@contoso.com'

@description('Specifies the current datetime')
param utcValue string = utcNow()

@description('Specifies the location.')
param location string = resourceGroup().location

@description('Specifies the resource tags.')
param tags object

// Variables
var clusterAdminRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', '0ab0b1a8-8aac-4efd-b8c2-3ee1fb270be8')

// Resources
resource aksCluster 'Microsoft.ContainerService/managedClusters@2022-11-02-preview' existing = {
  name: clusterName
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: managedIdentityName
  location: location
  tags: tags
}

resource clusterAdminContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name:  guid(managedIdentity.id, aksCluster.id, clusterAdminRoleDefinitionId)
  scope: aksCluster
  properties: {
    roleDefinitionId: clusterAdminRoleDefinitionId
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Script
resource deploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = if (deployPrometheusAndGrafanaViaHelm || deployCertificateManagerViaHelm || deployNginxIngressControllerViaHelm != 'None') {
  name: name
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    forceUpdateTag: utcValue
    azCliVersion: azCliVersion
    timeout: timeout
    environmentVariables: [
      {
        name: 'clusterName'
        value: clusterName
      }
      {
        name: 'resourceGroupName'
        value: resourceGroupName
      }
      {
        name: 'subscriptionId'
        value: subscriptionId
      }
      {
        name: 'deployPrometheusAndGrafanaViaHelm'
        value: deployPrometheusAndGrafanaViaHelm ? 'true' : 'false'
      }
      {
        name: 'ingressClassNames'
        value: join(ingressClassNames, ',')
      }
      {
        name: 'clusterIssuerNames'
        value: join(clusterIssuerNames, ',')
      }
      {
        name: 'deployCertificateManagerViaHelm'
        value: deployCertificateManagerViaHelm ? 'true' : 'false'
      }
      {
        name: 'deployNginxIngressControllerViaHelm'
        value: deployNginxIngressControllerViaHelm
      }
      {
        name: 'email'
        value: email
      }
    ]
    primaryScriptUri: primaryScriptUri
    cleanupPreference: cleanupPreference
    retentionInterval: retentionInterval
  }
}

// Outputs
output result object = deploymentScript.properties.outputs
output certManager string = deploymentScript.properties.outputs.certManager
output nginxIngressController string = deploymentScript.properties.outputs.nginxIngressController
