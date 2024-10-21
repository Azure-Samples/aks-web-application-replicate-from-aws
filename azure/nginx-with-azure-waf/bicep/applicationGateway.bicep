// Parameters
@description('Specifies the name of the Application Gateway.')
param name string

@description('Specifies the resource id of the user-defined managed identity of the Application Gateway.')
param managedIdentityId string

@description('Specifies the sku of the Application Gateway.')
param skuName string = 'WAF_v2'

@description('Specifies the frontend IP configuration type.')
@allowed([
  'Public'
  'Private'
  'Both'
])
param frontendIpConfigurationType string

@description('Specifies the name of the public IP adddress used by the Application Gateway.')
param publicIpAddressName string = '${name}PublicIp'

@description('Specifies the location of the Application Gateway.')
param location string

@description('Specifies the resource tags.')
param tags object

@description('Specifies the resource id of the subnet used by the Application Gateway.')
param subnetId string

@description('Specifies the private IP address of the Application Gateway.')
param privateIpAddress string

@description('Specifies the availability zones of the Application Gateway.')
param availabilityZones array

@description('Specifies the workspace id of the Log Analytics used to monitor the Application Gateway.')
param workspaceId string

@description('Specifies the lower bound on number of Application Gateway capacity.')
param minCapacity int = 1

@description('Specifies the upper bound on number of Application Gateway capacity.')
param maxCapacity int = 10

@description('Specifies an array containing custom probes.')
@metadata({
  name: 'Custom probe name'
  protocol: 'Custom probe protocol'
  path: 'Probe path'
  host: 'Probe host'
  interval: 'Integer containing probe interval'
  timeout: 'Integer containing probe timeout'
  unhealthyThreshold: 'Integer containing probe unhealthy threshold'
  pickHostNameFromBackendHttpSettings: 'Bool to enable pick host name from backend settings'
  minServers: 'Integer containing min servers'
  match: {
    statusCodes: [
      'Custom probe status codes'
    ]
  }
})
param probes array = []

@description('Specifies an array containing request routing rules.')
@metadata({
  name: 'Rule name'
  ruleType: 'Rule type'
  listener: 'Http listener name'
  priority: 'Integer containing rule priority'
  backendPool: 'Backend pool name'
  backendHttpSettings: 'Backend http setting name'
  redirectConfiguration: 'Redirection configuration name'
})
param requestRoutingRules array = []

@description('Specifies an array containing redirect configurations.')
@metadata({
  name: 'Redirecton name'
  redirectType: 'Redirect type'
  targetUrl: 'Target URL'
  includePath: 'Bool to include path'
  includeQueryString: 'Bool to include query string'
  requestRoutingRule: 'Name of request routing rule to associate redirection configuration'
})
param redirectConfigurations array = []

@description('Specifies an array containing http listeners.')
@metadata({
  name: 'Listener name'
  protocol: 'Listener protocol'
  frontendPort: 'Front end port name'
  sslCertificate: 'SSL certificate name'
  hostNames: 'Specifies an array containing host names'
  firewallPolicy: 'Enabled/Disabled. Configures firewall policy on listener'
})
param httpListeners array = []

@description('Specifies an array containing backend address pools.')
@metadata({
  name: 'Backend address pool name'
  backendAddresses: 'Specifies an array containing backend addresses'
})
param backendAddressPools array = []

@description('Array containing backend http settings')
@metadata({
  name: 'Backend http setting name'
  affinityCookieName: 'Cookie name to use for the affinity cookie.'
  authenticationCertificates: 'Array of references to application gateway authentication certificates.'
  connectionDraining: {
    drainTimeoutInSec: 'Integer containing connection drain timeout in seconds'
    enabled: 'Bool to enable connection draining'
  }
  cookieBasedAffinity: 'Enabled/Disabled. Configures cookie based affinity.'
  hostName: 'Backend http setting host name'
  path: 'Path which should be used as a prefix for all HTTP requests. Null means no path will be prefixed. Default value is null.'
  pickHostNameFromBackendAddress: 'Whether to pick host header should be picked from the host name of the backend server. Default value is false.'
  port: 'integer containing port number'
  probeName: 'Custom probe name'
  probeEnabled: 'Whether the probe is enabled. Default value is false.'
  protocol: 'Backend http setting protocol'
  requestTimeout: 'Integer containing backend http setting request timeout'
  trustedRootCertificate: 'Trusted root certificate name'
})
param backendHttpSettings array = []

@description('Specifies an array containing frontend ports.')
@metadata({
  name: 'Front port name'
  port: 'Integer containing port number'
})
param frontendPorts array = []

@description('Specifies an array containing trusted root certificates.')
@metadata({
  name: 'Certificate name'
  keyVaultSecretId: 'Key Vault Secret resouce id'
})
param trustedRootCertificates array = []

@description('Specifies an array containing ssl certificates.')
@metadata({
  name: 'Certificate name'
  keyVaultSecretId: 'Key Vault Secret resouce id'
})
param sslCertificates array = []

@description('Specifies the name of the WAF policy.')
param wafPolicyName string = '${name}WafPolicy'

@description('Specifies whether enable the WAF policy.')
param wafPolicyEnabled bool = true

@description('Specifies the mode of the WAF policy.')
@allowed([
  'Detection'
  'Prevention'
])
param wafPolicyMode string = 'Prevention'

@description('Specifies the state of the WAF policy.')
@allowed([
  'Enabled'
  'Disabled '
])
param wafPolicyState string = 'Enabled'

@description('Specifies the maximum file upload size in Mb for the WAF policy.')
param wafPolicyFileUploadLimitInMb int = 100

@description('Specifies the maximum request body size in Kb for the WAF policy.')
param wafPolicyMaxRequestBodySizeInKb int = 128

@description('Specifies the whether to allow WAF to check request Body.')
param wafPolicyRequestBodyCheck bool = true

@description('Specifies the rule set type.')
param wafPolicyRuleSetType string = 'OWASP'

@description('Specifies the rule set version.')
param wafPolicyRuleSetVersion string = '3.2'

// Variables
var diagnosticSettingsName = 'diagnosticSettings'
var gatewayIPConfigurationName = 'DefaultGatewayIpConfiguration'
var publicFrontendIPConfigurationName = 'PublicFrontendIPConfiguration'
var privateFrontendIPConfigurationName = 'PrivateFrontendIPConfiguration'
var frontendIPConfigurationName = frontendIpConfigurationType == 'Public'
  ? publicFrontendIPConfigurationName
  : privateFrontendIPConfigurationName
var applicationGatewayZones = !empty(availabilityZones) ? availabilityZones : []
var applicationGatewayLogCategories = [
  'ApplicationGatewayAccessLog'
  'ApplicationGatewayFirewallLog'
  'ApplicationGatewayPerformanceLog'
]
var publicFrontendIPConfiguration = {
  name: publicFrontendIPConfigurationName
  properties: {
    privateIPAllocationMethod: 'Dynamic'
    publicIPAddress: {
      id: applicationGatewayPublicIpAddress.id
    }
  }
}
var privateFrontendIPConfiguration = {
  name: privateFrontendIPConfigurationName
  properties: {
    privateIPAllocationMethod: 'Static'
    privateIPAddress: privateIpAddress
    subnet: {
      id: subnetId
    }
  }
}
var applicationGatewayMetricCategories = [
  'AllMetrics'
]
var applicationGatewayLogs = [
  for category in applicationGatewayLogCategories: {
    category: category
    enabled: true
  }
]
var applicationGatewayMetrics = [
  for category in applicationGatewayMetricCategories: {
    category: category
    enabled: true
  }
]

// Resources
resource applicationGatewayPublicIpAddress 'Microsoft.Network/publicIPAddresses@2024-01-01' = if (frontendIpConfigurationType != 'Private') {
  name: publicIpAddressName
  location: location
  zones: applicationGatewayZones
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource applicationGateway 'Microsoft.Network/applicationGateways@2024-01-01' = {
  name: name
  location: location
  tags: tags
  zones: applicationGatewayZones
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
  properties: {
    sku: {
      name: skuName
      tier: skuName
    }
    autoscaleConfiguration: {
      minCapacity: minCapacity
      maxCapacity: maxCapacity
    }
    trustedRootCertificates: [
      for trustedRootCertificate in trustedRootCertificates: {
        name: trustedRootCertificate.name
        properties: {
          keyVaultSecretId: trustedRootCertificate.?keyVaultSecretId
        }
      }
    ]
    sslCertificates: [
      for sslCertificate in sslCertificates: {
        name: sslCertificate.?name
        properties: {
          keyVaultSecretId: sslCertificate.?keyVaultSecretId
        }
      }
    ]
    gatewayIPConfigurations: [
      {
        name: gatewayIPConfigurationName
        properties: {
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    frontendIPConfigurations: union(
      frontendIpConfigurationType == 'Public' ? array(publicFrontendIPConfiguration) : [],
      frontendIpConfigurationType == 'Private' ? array(privateFrontendIPConfiguration) : [],
      frontendIpConfigurationType == 'Both' ? concat(array(publicFrontendIPConfiguration), array(privateFrontendIPConfiguration)) : []
    )
    frontendPorts: [for frontendPort in frontendPorts: {
      name: frontendPort.name
      properties: {
        port: frontendPort.port
      }
    }]
    probes: [for probe in probes: {
      name: probe.name
      properties: {
        protocol: probe.?protocol
        path: probe.?path
        host: probe.?host
        interval: probe.?interval != null ? probe.interval : 30
        timeout: probe.?timeout != null ? probe.timeout : 30
        unhealthyThreshold: probe.unhealthyThreshold != null ? probe.unhealthyThreshold : 3
        pickHostNameFromBackendHttpSettings: probe.?PickHostNameFromBackendHttpSettings != null ? probe.pickHostNameFromBackendHttpSettings : false
        match: probe.?match 
      }
    }]
    backendAddressPools: [for backendAddressPool in backendAddressPools: {
      name: backendAddressPool.name
      properties: {
        backendAddresses: backendAddressPool.?backendAddresses
      }
    }]
    firewallPolicy: wafPolicyEnabled
      ? {
          id: wafPolicy.id
        }
      : null
      backendHttpSettingsCollection: [for backendHttpSetting in backendHttpSettings: {
        name: backendHttpSetting.name
        properties: {
          authenticationCertificates: backendHttpSetting.?authenticationCertificates != null ? json('[{"id": "${resourceId('Microsoft.Network/applicationGateways/authenticationCertificates', name, backendHttpSetting.authenticationCertificates)}"}]') : null
          affinityCookieName: backendHttpSetting.?affinityCookieName
          connectionDraining: backendHttpSetting.?connectionDraining
          cookieBasedAffinity: backendHttpSetting.?cookieBasedAffinity ?? 'Disabled'
          hostName: backendHttpSetting.?hostName
          path: backendHttpSetting.?path
          pickHostNameFromBackendAddress: backendHttpSetting.?pickHostNameFromBackendAddress != null ? backendHttpSetting.pickHostNameFromBackendAddress : false
          port: backendHttpSetting.?port != null ? backendHttpSetting.port : 80
          protocol: backendHttpSetting.?protocol ?? 'Http'
          probe: backendHttpSetting.?probeName != null ? json('{"id": "${resourceId('Microsoft.Network/applicationGateways/probes', name, backendHttpSetting.probeName)}"}') : null
          probeEnabled: backendHttpSetting.?probeEnabled  != null ? backendHttpSetting.probeEnabled : false
          requestTimeout: backendHttpSetting.?requestTimeout  != null ? backendHttpSetting.requestTimeout : 30
          trustedRootCertificates: backendHttpSetting.?trustedRootCertificate != null ? json('[{"id": "${resourceId('Microsoft.Network/applicationGateways/trustedRootCertificates', name, backendHttpSetting.trustedRootCertificate)}"}]') : null
        }
      }]
      httpListeners: [for httpListener in httpListeners: {
        name: httpListener.name
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', name, frontendIPConfigurationName)
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', name, httpListener.frontendPort)
          }
          protocol: httpListener.?protocol ?? 'Http'
          sslCertificate: httpListener.?sslCertificate  != null ? json('{"id": "${resourceId('Microsoft.Network/applicationGateways/sslCertificates', name, httpListener.sslCertificate)}"}') : null
          hostNames: httpListener.?hostNames  ?? null
          hostName: httpListener.?hostName ?? null
          requireServerNameIndication: httpListener.?protocol == 'Https' && httpListener.?requireServerNameIndication != null ?? false
          firewallPolicy: httpListener.?firewallPolicy == 'Enabled' ? json('{"id": "${wafPolicy.id}"}') : null
        }
      }]
      requestRoutingRules: [for rule in requestRoutingRules: {
        name: rule.name
        properties: {
          ruleType: rule.ruleType
          priority: rule.?priority ?? 1000
          httpListener: rule.?listener  != null ? json('{"id": "${resourceId('Microsoft.Network/applicationGateways/httpListeners', name, rule.listener)}"}') : null
          backendAddressPool: rule.?backendPool  != null ? json('{"id": "${resourceId('Microsoft.Network/applicationGateways/backendAddressPools', name, rule.backendPool)}"}') : null
          backendHttpSettings: rule.?backendHttpSettings  != null ? json('{"id": "${resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', name, rule.backendHttpSettings)}"}') : null
          redirectConfiguration: rule.? redirectConfiguration  != null ? json('{"id": "${resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', name, rule.redirectConfiguration)}"}') : null
        }
      }]
      redirectConfigurations: [for redirectConfiguration in redirectConfigurations: {
        name: redirectConfiguration.name
        properties: {
          redirectType: redirectConfiguration.redirectType
          targetUrl: redirectConfiguration.targetUrl
          targetListener: redirectConfiguration.?targetListener  != null ? json('{"id": "${resourceId('Microsoft.Network/applicationGateways/httpListeners', name, redirectConfiguration.targetListener)}"}') : null
          includePath: redirectConfiguration.includePath
          includeQueryString: redirectConfiguration.includeQueryString
          requestRoutingRules: [
            {
              id: resourceId('Microsoft.Network/applicationGateways/requestRoutingRules', name, redirectConfiguration.requestRoutingRule)
            }
          ]
        }
      }]
  }
}

resource wafPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2024-01-01' = {
  name: wafPolicyName
  location: location
  tags: tags
  properties: {
    customRules: [
      {
        name: 'BlockMe'
        priority: 1
        ruleType: 'MatchRule'
        action: 'Block'
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'QueryString'
              }
            ]
            operator: 'Contains'
            negationConditon: false
            matchValues: [
              'blockme'
            ]
          }
        ]
      }
      {
        name: 'BlockEvilBot'
        priority: 2
        ruleType: 'MatchRule'
        action: 'Block'
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'RequestHeaders'
                selector: 'User-Agent'
              }
            ]
            operator: 'Contains'
            negationConditon: false
            matchValues: [
              'evilbot'
            ]
            transforms: [
              'Lowercase'
            ]
          }
        ]
      }
    ]
    policySettings: {
      requestBodyCheck: wafPolicyRequestBodyCheck
      maxRequestBodySizeInKb: wafPolicyMaxRequestBodySizeInKb
      fileUploadLimitInMb: wafPolicyFileUploadLimitInMb
      mode: wafPolicyMode
      state: wafPolicyState
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: wafPolicyRuleSetType
          ruleSetVersion: wafPolicyRuleSetVersion
        }
      ]
    }
  }
}

resource applicationGatewayDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: applicationGateway
  properties: {
    workspaceId: workspaceId
    logs: applicationGatewayLogs
    metrics: applicationGatewayMetrics
  }
}

// Outputs
output id string = applicationGateway.id
output name string = applicationGateway.name
