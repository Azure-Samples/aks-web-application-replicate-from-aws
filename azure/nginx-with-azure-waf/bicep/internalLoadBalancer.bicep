// Parameters
@description('Specifies the name of the load balancer.')
param name string

@description('Specifies the name of the resource group containing the load balancer.')
param resourceGroupName string

// Resources
resource loadBalancer 'Microsoft.Network/loadBalancers@2024-01-01' existing = {
  name: name
  scope: resourceGroup(resourceGroupName)
}

// Outputs
output privateIpAddress string = loadBalancer.properties.frontendIPConfigurations[0].properties.privateIPAddress
