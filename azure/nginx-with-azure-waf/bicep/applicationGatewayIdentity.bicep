// Parameters
@description('Specifies the name of the user-defined managed identity of the Application Gateway.')
param managedIdentityName string

@description('Specifies the location of the user-defined managed identity  of the Application Gateway.')
param location string = resourceGroup().location

@description('Specifies the resource tags.')
param tags object

// Resources
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: managedIdentityName
  location: location
  tags: tags
}

// Outputs
output id string = managedIdentity.id
output name string = managedIdentity.name
output principalId string = managedIdentity.properties.principalId
