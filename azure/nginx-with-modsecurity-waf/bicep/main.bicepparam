using './main.bicep'

// Parameters
param aksClusterNetworkMode = 'transparent'
param aksClusterNetworkDataplane = 'cilium'
param aksClusterNetworkPlugin = 'azure'
param aksClusterNetworkPluginMode = 'overlay'
param aksClusterNetworkPolicy = 'cilium'
param aksClusterWebAppRoutingEnabled = true
param aksClusterNginxDefaultIngressControllerType = 'Internal'
param aksClusterSkuTier = 'Standard'
param aksClusterPodCidr = '192.168.0.0/16'
param aksClusterServiceCidr = '172.16.0.0/16'
param aksClusterDnsServiceIP = '172.16.0.10'
param aksClusterOutboundType = 'userAssignedNATGateway'
param aksClusterKubernetesVersion = '1.30.4'
param aksClusterAdminUsername = 'azadmin'
param aksClusterSshPublicKey = getSecret(
  '5b88bb04-3d20-4aac-bfef-603c1e311ef2',
  'HorusRG',
  'HorusKeyVault',
  'aksClusterSshPublicKey'
)
param loadBalancerBackendPoolType = 'nodeIP'
param aadProfileManaged = true
param aadProfileEnableAzureRBAC = true
param aadProfileAdminGroupObjectIDs = [
  '4e4d0501-e693-4f3e-965b-5bec6c410c03'
]
param systemAgentPoolName = 'system'
param systemAgentPoolVmSize = 'Standard_F8s_v2'
param systemAgentPoolOsDiskSizeGB = 80
param systemAgentPoolAgentCount = 3
param systemAgentPoolMaxCount = 5
param systemAgentPoolMinCount = 3
param systemAgentPoolNodeTaints = [
  'CriticalAddonsOnly=true:NoSchedule'
]
param userAgentPoolName = 'user'
param userAgentPoolVmSize = 'Standard_F8s_v2'
param userAgentPoolOsDiskSizeGB = 80
param userAgentPoolAgentCount = 3
param userAgentPoolMaxCount = 5
param userAgentPoolMinCount = 3
param enableVnetIntegration = true
param virtualNetworkAddressPrefixes = '10.0.0.0/8'
param systemAgentPoolSubnetName = 'SystemSubnet'
param systemAgentPoolSubnetAddressPrefix = '10.240.0.0/16'
param userAgentPoolSubnetName = 'UserSubnet'
param userAgentPoolSubnetAddressPrefix = '10.241.0.0/16'
param podSubnetName = 'PodSubnet'
param podSubnetAddressPrefix = '10.242.0.0/16'
param apiServerSubnetName = 'ApiServerSubnet'
param apiServerSubnetAddressPrefix = '10.243.0.0/27'
param vmSubnetName = 'VmSubnet'
param vmSubnetAddressPrefix = '10.243.1.0/24'
param bastionSubnetAddressPrefix = '10.243.2.0/24'
param logAnalyticsSku = 'PerGB2018'
param logAnalyticsRetentionInDays = 60
param vmEnabled = true
param vmName = 'TestVm'
param vmSize = 'Standard_F8s_v2'
param imagePublisher = 'Canonical'
param imageOffer = '0001-com-ubuntu-server-jammy'
param imageSku = '22_04-lts-gen2'
param authenticationType = 'sshPublicKey'
param vmAdminUsername = 'azadmin'
param vmAdminPasswordOrKey = getSecret(
  '5b88bb04-3d20-4aac-bfef-603c1e311ef2',
  'HorusRG',
  'HorusKeyVault',
  'vmAdminSshPublicKey'
)
param diskStorageAccountType = 'Premium_LRS'
param numDataDisks = 1
param osDiskSize = 50
param dataDiskSize = 50
param dataDiskCaching = 'ReadWrite'
param aksClusterEnablePrivateCluster = false
param aksEnablePrivateClusterPublicFQDN = false
param podIdentityProfileEnabled = false
param kedaEnabled = true
param daprEnabled = true
param fluxGitOpsEnabled = false
param verticalPodAutoscalerEnabled = true
param deploymentScriptUri = 'https://raw.githubusercontent.com/paolosalvatori/yelb/refs/heads/main/azure/nginx-with-modsecurity-waf/bicep/install-nginx-ingress-controller-with-modsecurity.sh'
param blobCSIDriverEnabled = true
param diskCSIDriverEnabled = true
param fileCSIDriverEnabled = true
param snapshotControllerEnabled = true
param defenderSecurityMonitoringEnabled = true
param imageCleanerEnabled = true
param imageCleanerIntervalHours = 24
param nodeRestrictionEnabled = true
param workloadIdentityEnabled = true
param oidcIssuerProfileEnabled = true
param dnsZoneName = 'babosbird.com'
param dnsZoneResourceGroupName = 'DnsResourceGroup'
param actionGroupEmailAddress = 'paolos@microsoft.com'
param deployPrometheusAndGrafanaViaHelm = true
param deployCertificateManagerViaHelm = true
param ingressClassNames = ['nginx','webapprouting.kubernetes.azure.com']
param clusterIssuerNames = ['letsencrypt-nginx','letsencrypt-webapprouting']
param deployNginxIngressControllerViaHelm = 'External'
param email = 'paolos@microsoft.com'
