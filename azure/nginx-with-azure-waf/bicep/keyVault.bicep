// Parameters
@description('Specifies the name of an existing Key Vault resource holding the TLS certificate.')
param name string

@description('Specifies the object id of the Key Vault CSI Driver user-assigned managed identity.')
param aksManagedIdentityObjectId string

@description('Specifies the principal id of the Application Gateway user-assigned managed identity.')
param applicationGatewayManagedIdentityPrincipalId string

@description('Specifies whether the Azure Key Vault Provider for Secrets Store CSI Driver addon is enabled or not.')
param azureKeyvaultSecretsProviderEnabled bool = true

// Resources
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: name
}

// Role Definitions
resource keyVaultAdministratorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '00482a5a-887f-4fb3-b363-3b7fe8e74483'
  scope: subscription()
}

resource keyVaultSecretsUserRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '4633458b-17de-408a-b874-0445c86b69e6'
  scope: subscription()
}

// Role Assignments
resource keyVaultCSIdriverSecretsUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (azureKeyvaultSecretsProviderEnabled) {
  name: guid(keyVault.id, 'CSIDriver', keyVaultAdministratorRoleDefinition.id, aksManagedIdentityObjectId)
  scope: keyVault
  properties: {
    roleDefinitionId: keyVaultAdministratorRoleDefinition.id
    principalType: 'ServicePrincipal'
    principalId: aksManagedIdentityObjectId
  }
}

resource keyVaultSecretsUserApplicationGatewayIdentityRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, applicationGatewayManagedIdentityPrincipalId, keyVaultSecretsUserRoleDefinition.id)
  properties: {
    roleDefinitionId: keyVaultSecretsUserRoleDefinition.id
    principalType: 'ServicePrincipal'
    principalId: applicationGatewayManagedIdentityPrincipalId
  }
}

// Outputs
output id string = keyVault.id
output name string = keyVault.name
output vaultUri string = keyVault.properties.vaultUri
