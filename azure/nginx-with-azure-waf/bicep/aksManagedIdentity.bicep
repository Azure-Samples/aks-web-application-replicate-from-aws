// Parameters
@description('Specifies the name of the user-defined managed identity.')
param managedIdentityName string

@description('Specifies the name of the existing virtual network.')
param virtualNetworkName string

@description('Specifies the location of the user-defined managed identity.')
param location string = resourceGroup().location

@description('Specifies the resource tags.')
param tags object

// Variables
var networkContributorRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7')

// Resources
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: managedIdentityName
  location: location
  tags: tags
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' existing =  {
  name: virtualNetworkName
}


resource virtualNetworkContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name:  guid(managedIdentity.id, virtualNetwork.id, networkContributorRoleDefinitionId)
  scope: virtualNetwork
  properties: {
    roleDefinitionId: networkContributorRoleDefinitionId
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Outputs
output id string = managedIdentity.id
output name string = managedIdentity.name
