@description('Specifies the prefix for all the Azure resources.')
param prefix string = uniqueString(resourceGroup().id)

@description('Specifies the object id of an Azure Active Directory user. In general, this the object id of the system administrator who deploys the Azure resources.')
param userId string = ''

@description('Specifies whether name resources are in CamelCase, UpperCamelCase, or KebabCase.')
@allowed([
  'CamelCase'
  'UpperCamelCase'
  'KebabCase'
])
param letterCaseType string = 'UpperCamelCase'

@description('Specifies the location of the AKS cluster.')
param location string = resourceGroup().location

@description('Specifies the name of the AKS cluster.')
param aksClusterName string = letterCaseType == 'UpperCamelCase'
  ? '${toUpper(first(prefix))}${toLower(substring(prefix, 1, length(prefix) - 1))}Aks'
  : letterCaseType == 'CamelCase' ? '${toLower(prefix)}Aks' : '${toLower(prefix)}-aks'

@description('Specifies whether creating metric alerts or not.')
param createMetricAlerts bool = true

@description('Specifies whether metric alerts as either enabled or disabled.')
param metricAlertsEnabled bool = true

@description('Specifies metric alerts eval frequency.')
param metricAlertsEvalFrequency string = 'PT1M'

@description('Specifies metric alerts window size.')
param metricAlertsWindowsSize string = 'PT1H'

@description('Specifies the DNS prefix specified when creating the managed cluster.')
param aksClusterDnsPrefix string = aksClusterName

@description('Specifies the network plugin used for building Kubernetes network. - azure or kubenet.')
@allowed([
  'azure'
  'kubenet'
])
param aksClusterNetworkPlugin string = 'azure'

@description('Specifies the Network plugin mode used for building the Kubernetes network.')
@allowed([
  ''
  'overlay'
])
param aksClusterNetworkPluginMode string = ''

@description('Specifies the network policy used for building Kubernetes network. - calico or azure')
@allowed([
  'azure'
  'calico'
  'cilium'
  'none'
])
param aksClusterNetworkPolicy string = 'azure'

@description('Specifies the network dataplane used in the Kubernetes cluster..')
@allowed([
  'azure'
  'cilium'
])
param aksClusterNetworkDataplane string = 'azure'

@description('Specifies the network mode. This cannot be specified if networkPlugin is anything other than azure.')
@allowed([
  'bridge'
  'transparent'
])
param aksClusterNetworkMode string = 'transparent'

@description('Specifies the CIDR notation IP range from which to assign pod IPs when kubenet is used.')
param aksClusterPodCidr string = '192.168.0.0/16'

@description('A CIDR notation IP range from which to assign service cluster IPs. It must not overlap with any Subnet IP ranges.')
param aksClusterServiceCidr string = '172.16.0.0/16'

@description('Specifies the IP address assigned to the Kubernetes DNS service. It must be within the Kubernetes service address range specified in serviceCidr.')
param aksClusterDnsServiceIP string = '172.16.0.10'

@description('Specifies the sku of the load balancer used by the virtual machine scale sets used by nodepools.')
@allowed([
  'basic'
  'standard'
])
param aksClusterLoadBalancerSku string = 'standard'

@description('Specifies the type of the managed inbound Load Balancer BackendPool.')
@allowed([
  'nodeIP'
  'nodeIPConfiguration'
])
param loadBalancerBackendPoolType string = 'nodeIPConfiguration'

@description('Specifies Advanced Networking profile for enabling observability on a cluster. Note that enabling advanced networking features may incur additional costs. For more information see aka.ms/aksadvancednetworking.')
param advancedNetworking object = {
  observability: {
    enabled: true
    tlsManagement: 'Managed'
  }
  security: aksClusterNetworkDataplane == 'cilium'
    ? {
        fqdnPolicy: {
          enabled: true
        }
      }
    : null
}

@description('Specifies the IP families are used to determine single-stack or dual-stack clusters. For single-stack, the expected value is IPv4. For dual-stack, the expected values are IPv4 and IPv6.')
param aksClusterIpFamilies array = ['IPv4']

@description('Specifies outbound (egress) routing method. - loadBalancer or userDefinedRouting.')
@allowed([
  'loadBalancer'
  'managedNATGateway'
  'userAssignedNATGateway'
  'userDefinedRouting'
])
param aksClusterOutboundType string = 'loadBalancer'

@description('Specifies the tier of a managed cluster SKU: Paid or Free')
@allowed([
  'Free'
  'Standard'
  'Premium'
])
param aksClusterSkuTier string = 'Standard'

@description('Specifies the version of Kubernetes specified when creating the managed cluster.')
param aksClusterKubernetesVersion string = '1.18.8'

@description('Specifies the administrator username of Linux virtual machines.')
param aksClusterAdminUsername string = 'azureuser'

@description('Specifies the SSH RSA public key string for the Linux nodes.')
param aksClusterSshPublicKey string

@description('Specifies the tenant id of the Azure Active Directory used by the AKS cluster for authentication.')
param aadProfileTenantId string = subscription().tenantId

@description('Specifies the AAD group object IDs that will have admin role of the cluster.')
param aadProfileAdminGroupObjectIDs array = []

@description('Specifies the node OS upgrade channel. The default is Unmanaged, but may change to either NodeImage or SecurityPatch at GA.	.')
@allowed([
  'NodeImage'
  'None'
  'SecurityPatch'
  'Unmanaged'
])
param aksClusterNodeOSUpgradeChannel string = 'Unmanaged'

@description('Specifies the upgrade channel for auto upgrade. Allowed values include rapid, stable, patch, node-image, none.')
@allowed([
  'rapid'
  'stable'
  'patch'
  'node-image'
  'none'
])
param aksClusterUpgradeChannel string = 'stable'

@description('Specifies whether to create the cluster as a private cluster or not.')
param aksClusterEnablePrivateCluster bool = true

@description('Specifies whether the managed NGINX Ingress Controller application routing addon is enabled.')
param aksClusterWebAppRoutingEnabled bool = true

@description('Specifies the ingress type for the default NginxIngressController custom resource.')
@allowed([
  'AnnotationControlled'
  'External'
  'Internal'
  'None'
])
param aksClusterNginxDefaultIngressControllerType string = 'Internal'

@description('Specifies the Private DNS Zone mode for private cluster. When the value is equal to None, a Public DNS Zone is used in place of a Private DNS Zone')
param aksPrivateDNSZone string = 'none'

@description('Specifies whether to create additional public FQDN for private cluster or not.')
param aksEnablePrivateClusterPublicFQDN bool = true

@description('Specifies whether to enable managed AAD integration.')
param aadProfileManaged bool = true

@description('Specifies whether to  to enable Azure RBAC for Kubernetes authorization.')
param aadProfileEnableAzureRBAC bool = true

@description('Specifies the unique name of of the system node pool profile in the context of the subscription and resource group.')
param systemAgentPoolName string = 'nodepool1'

@description('Specifies the vm size of nodes in the system node pool.')
param systemAgentPoolVmSize string = 'Standard_DS5_v2'

@description('Specifies the OS Disk Size in GB to be used to specify the disk size for every machine in the system agent pool. If you specify 0, it will apply the default osDisk size according to the vmSize specified.')
param systemAgentPoolOsDiskSizeGB int = 100

@description('Specifies the OS disk type to be used for machines in a given agent pool. Allowed values are \'Ephemeral\' and \'Managed\'. If unspecified, defaults to \'Ephemeral\' when the VM supports ephemeral OS and has a cache disk larger than the requested OSDiskSizeGB. Otherwise, defaults to \'Managed\'. May not be changed after creation. - Managed or Ephemeral')
@allowed([
  'Ephemeral'
  'Managed'
])
param systemAgentPoolOsDiskType string = 'Ephemeral'

@description('Specifies the number of agents (VMs) to host docker containers in the system node pool. Allowed values must be in the range of 1 to 100 (inclusive). The default value is 1.')
param systemAgentPoolAgentCount int = 3

@description('Specifies the OS type for the vms in the system node pool. Choose from Linux and Windows. Default to Linux.')
@allowed([
  'Linux'
  'Windows'
])
param systemAgentPoolOsType string = 'Linux'

@description('Specifies the OS SKU used by the system agent pool. If not specified, the default is Ubuntu if OSType=Linux or Windows2019 if OSType=Windows. And the default Windows OSSKU will be changed to Windows2022 after Windows2019 is deprecated.')
@allowed([
  'Ubuntu'
  'Windows2019'
  'Windows2022'
  'AzureLinux'
])
param systemAgentPoolOsSKU string = 'Ubuntu'

@description('Specifies the maximum number of pods that can run on a node in the system node pool. The maximum number of pods per node in an AKS cluster is 250. The default maximum number of pods per node varies between kubenet and Azure CNI networking, and the method of cluster deployment.')
param systemAgentPoolMaxPods int = 30

@description('Specifies the maximum number of nodes for auto-scaling for the system node pool.')
param systemAgentPoolMaxCount int = 5

@description('Specifies the minimum number of nodes for auto-scaling for the system node pool.')
param systemAgentPoolMinCount int = 3

@description('Specifies whether to enable auto-scaling for the system node pool.')
param systemAgentPoolEnableAutoScaling bool = true

@description('Specifies the virtual machine scale set priority in the system node pool: Spot or Regular.')
@allowed([
  'Spot'
  'Regular'
])
param systemAgentPoolScaleSetPriority string = 'Regular'

@description('Specifies the ScaleSetEvictionPolicy to be used to specify eviction policy for spot virtual machine scale set. Default to Delete. Allowed values are Delete or Deallocate.')
@allowed([
  'Delete'
  'Deallocate'
])
param systemAgentPoolScaleSetEvictionPolicy string = 'Delete'

@description('Specifies the Agent pool node labels to be persisted across all nodes in the system node pool.')
param systemAgentPoolNodeLabels object = {}

@description('Specifies the taints added to new nodes during node pool create and scale. For example, key=value:NoSchedule.')
param systemAgentPoolNodeTaints array = []

@description('Determines the placement of emptyDir volumes, container runtime data root, and Kubelet ephemeral storage.')
@allowed([
  'OS'
  'Temporary'
])
param systemAgentPoolKubeletDiskType string = 'OS'

@description('Specifies the type for the system node pool: VirtualMachineScaleSets or AvailabilitySet')
@allowed([
  'VirtualMachineScaleSets'
  'AvailabilitySet'
])
param systemAgentPoolType string = 'VirtualMachineScaleSets'

@description('Specifies the availability zones for the agent nodes in the system node pool. Requirese the use of VirtualMachineScaleSets as node pool type.')
param systemAgentPoolAvailabilityZones array = [
  '1'
  '2'
  '3'
]

@description('Specifies the unique name of of the user node pool profile in the context of the subscription and resource group.')
param userAgentPoolName string = 'nodepool1'

@description('Specifies the vm size of nodes in the user node pool.')
param userAgentPoolVmSize string = 'Standard_DS5_v2'

@description('Specifies the OS Disk Size in GB to be used to specify the disk size for every machine in the system agent pool. If you specify 0, it will apply the default osDisk size according to the vmSize specified..')
param userAgentPoolOsDiskSizeGB int = 100

@description('Specifies the OS disk type to be used for machines in a given agent pool. Allowed values are \'Ephemeral\' and \'Managed\'. If unspecified, defaults to \'Ephemeral\' when the VM supports ephemeral OS and has a cache disk larger than the requested OSDiskSizeGB. Otherwise, defaults to \'Managed\'. May not be changed after creation. - Managed or Ephemeral')
@allowed([
  'Ephemeral'
  'Managed'
])
param userAgentPoolOsDiskType string = 'Ephemeral'

@description('Specifies the number of agents (VMs) to host docker containers in the user node pool. Allowed values must be in the range of 1 to 100 (inclusive). The default value is 1.')
param userAgentPoolAgentCount int = 3

@description('Specifies the OS type for the vms in the user node pool. Choose from Linux and Windows. Default to Linux.')
@allowed([
  'Linux'
  'Windows'
])
param userAgentPoolOsType string = 'Linux'

@description('Specifies the OS SKU used by the system agent pool. If not specified, the default is Ubuntu if OSType=Linux or Windows2019 if OSType=Windows. And the default Windows OSSKU will be changed to Windows2022 after Windows2019 is deprecated.')
@allowed([
  'Ubuntu'
  'Windows2019'
  'Windows2022'
  'AzureLinux'
])
param userAgentPoolOsSKU string = 'Ubuntu'

@description('Specifies the maximum number of pods that can run on a node in the user node pool. The maximum number of pods per node in an AKS cluster is 250. The default maximum number of pods per node varies between kubenet and Azure CNI networking, and the method of cluster deployment.')
param userAgentPoolMaxPods int = 30

@description('Specifies the maximum number of nodes for auto-scaling for the user node pool.')
param userAgentPoolMaxCount int = 5

@description('Specifies the minimum number of nodes for auto-scaling for the user node pool.')
param userAgentPoolMinCount int = 3

@description('Specifies whether to enable auto-scaling for the user node pool.')
param userAgentPoolEnableAutoScaling bool = true

@description('Specifies the virtual machine scale set priority in the user node pool: Spot or Regular.')
@allowed([
  'Spot'
  'Regular'
])
param userAgentPoolScaleSetPriority string = 'Regular'

@description('Specifies the ScaleSetEvictionPolicy to be used to specify eviction policy for spot virtual machine scale set. Default to Delete. Allowed values are Delete or Deallocate.')
@allowed([
  'Delete'
  'Deallocate'
])
param userAgentPoolScaleSetEvictionPolicy string = 'Delete'

@description('Specifies the Agent pool node labels to be persisted across all nodes in the user node pool.')
param userAgentPoolNodeLabels object = {}

@description('Specifies the taints added to new nodes during node pool create and scale. For example, key=value:NoSchedule.')
param userAgentPoolNodeTaints array = []

@description('Determines the placement of emptyDir volumes, container runtime data root, and Kubelet ephemeral storage.')
@allowed([
  'OS'
  'Temporary'
])
param userAgentPoolKubeletDiskType string = 'OS'

@description('Specifies the type for the user node pool: VirtualMachineScaleSets or AvailabilitySet')
@allowed([
  'VirtualMachineScaleSets'
  'AvailabilitySet'
])
param userAgentPoolType string = 'VirtualMachineScaleSets'

@description('Specifies the availability zones for the agent nodes in the user node pool. Requirese the use of VirtualMachineScaleSets as node pool type.')
param userAgentPoolAvailabilityZones array = [
  '1'
  '2'
  '3'
]

@description('Specifies whether the httpApplicationRouting add-on is enabled or not.')
param httpApplicationRoutingEnabled bool = false

@description('Specifies whether the Istio Service Mesh add-on is enabled or not.')
param istioServiceMeshEnabled bool = false

@description('Specifies whether the Istio Ingress Gateway is enabled or not.')
param istioIngressGatewayEnabled bool = false

@description('Specifies the type of the Istio Ingress Gateway.')
@allowed([
  'Internal'
  'External'
])
param istioIngressGatewayType string = 'External'

@description('Specifies whether the Kubernetes Event-Driven Autoscaler (KEDA) add-on is enabled or not.')
param kedaEnabled bool = false

@description('Specifies whether the Dapr extension is enabled or not.')
param daprEnabled bool = false

@description('Enable high availability (HA) mode for the Dapr control plane')
param daprHaEnabled bool = false

@description('Specifies whether the Flux V2 extension is enabled or not.')
param fluxGitOpsEnabled bool = false

@description('Specifies whether the Vertical Pod Autoscaler is enabled or not.')
param verticalPodAutoscalerEnabled bool = false

@description('Specifies whether the aciConnectorLinux add-on is enabled or not.')
param aciConnectorLinuxEnabled bool = false

@description('Specifies whether the azurepolicy add-on is enabled or not.')
param azurePolicyEnabled bool = true

@description('Specifies whether the Azure Key Vault Provider for Secrets Store CSI Driver addon is enabled or not.')
param azureKeyvaultSecretsProviderEnabled bool = true

@description('Specifies whether the kubeDashboard add-on is enabled or not.')
param kubeDashboardEnabled bool = false

@description('Specifies whether the pod identity addon is enabled..')
param podIdentityProfileEnabled bool = false

@description('Specifies the scan interval of the auto-scaler of the AKS cluster.')
param autoScalerProfileScanInterval string = '10s'

@description('Specifies the scale down delay after add of the auto-scaler of the AKS cluster.')
param autoScalerProfileScaleDownDelayAfterAdd string = '10m'

@description('Specifies the scale down delay after delete of the auto-scaler of the AKS cluster.')
param autoScalerProfileScaleDownDelayAfterDelete string = '20s'

@description('Specifies scale down delay after failure of the auto-scaler of the AKS cluster.')
param autoScalerProfileScaleDownDelayAfterFailure string = '3m'

@description('Specifies the scale down unneeded time of the auto-scaler of the AKS cluster.')
param autoScalerProfileScaleDownUnneededTime string = '10m'

@description('Specifies the scale down unready time of the auto-scaler of the AKS cluster.')
param autoScalerProfileScaleDownUnreadyTime string = '20m'

@description('Specifies the utilization threshold of the auto-scaler of the AKS cluster.')
param autoScalerProfileUtilizationThreshold string = '0.5'

@description('Specifies the max graceful termination time interval in seconds for the auto-scaler of the AKS cluster.')
param autoScalerProfileMaxGracefulTerminationSec string = '600'

@description('Specifies whether to enable API server VNET integration for the cluster or not.')
param enableVnetIntegration bool = true

@description('Specifies the name of the virtual network.')
param virtualNetworkName string = letterCaseType == 'UpperCamelCase'
  ? '${toUpper(first(prefix))}${toLower(substring(prefix, 1, length(prefix) - 1))}VNet'
  : letterCaseType == 'CamelCase' ? '${toLower(prefix)}VNet' : '${toLower(prefix)}-vnet'

@description('Specifies the address prefixes of the virtual network.')
param virtualNetworkAddressPrefixes string = '10.0.0.0/8'

@description('Specifies the name of the subnet hosting the worker nodes of the default system agent pool of the AKS cluster.')
param systemAgentPoolSubnetName string = 'SystemSubnet'

@description('Specifies the address prefix of the subnet hosting the worker nodes of the default system agent pool of the AKS cluster.')
param systemAgentPoolSubnetAddressPrefix string = '10.0.0.0/16'

@description('Specifies the name of the subnet hosting the worker nodes of the user agent pool of the AKS cluster.')
param userAgentPoolSubnetName string = 'UserSubnet'

@description('Specifies the address prefix of the subnet hosting the worker nodes of the user agent pool of the AKS cluster.')
param userAgentPoolSubnetAddressPrefix string = '10.1.0.0/16'

@description('Specifies the name of the subnet which contains the Application Gateway.')
param applicationGatewaySubnetName string = 'AppGatewaySubnet'

@description('Specifies the address prefix of the subnet which contains the Application Gateway.')
param applicationGatewaySubnetAddressPrefix string = '10.4.0.0/24'

@description('Specifies whether to enable the Azure Blob CSI Driver. The default value is false.')
param blobCSIDriverEnabled bool = false

@description('Specifies whether to enable the Azure Disk CSI Driver. The default value is true.')
param diskCSIDriverEnabled bool = true

@description('Specifies whether to enable the Azure File CSI Driver. The default value is true.')
param fileCSIDriverEnabled bool = true

@description('Specifies whether to enable the Snapshot Controller. The default value is true.')
param snapshotControllerEnabled bool = true

@description('Specifies whether to enable Defender threat detection. The default value is false.')
param defenderSecurityMonitoringEnabled bool = false

@description('Specifies whether to enable ImageCleaner on AKS cluster. The default value is false.')
param imageCleanerEnabled bool = false

@description('Specifies whether ImageCleaner scanning interval in hours.')
param imageCleanerIntervalHours int = 24

@description('Specifies whether to enable Node Restriction. The default value is false.')
param nodeRestrictionEnabled bool = false

@description('Specifies whether to enable Workload Identity. The default value is false.')
param workloadIdentityEnabled bool = true

@description('Specifies whether the OIDC issuer is enabled.')
param oidcIssuerProfileEnabled bool = true

@description('Specifies the name of the subnet hosting the pods running in the AKS cluster.')
param podSubnetName string = letterCaseType == 'UpperCamelCase'
  ? 'PodSubnet'
  : letterCaseType == 'CamelCase' ? 'podSubnet' : 'pod-subnet'

@description('Specifies the address prefix of the subnet hosting the pods running in the AKS cluster.')
param podSubnetAddressPrefix string = '10.2.0.0/16'

@description('Specifies the name of the subnet delegated to the API server when configuring the AKS cluster to use API server VNET integration.')
param apiServerSubnetName string = letterCaseType == 'UpperCamelCase'
  ? 'ApiServerSubnet'
  : letterCaseType == 'CamelCase' ? 'apiServerSubnet' : 'api-server-subnet'

@description('Specifies the address prefix of the subnet delegated to the API server when configuring the AKS cluster to use API server VNET integration.')
param apiServerSubnetAddressPrefix string = '10.3.0.0/28'

@description('Specifies the name of the subnet which contains the virtual machine.')
param vmSubnetName string = letterCaseType == 'UpperCamelCase'
  ? 'VmSubnet'
  : letterCaseType == 'CamelCase' ? 'vmSubnet' : 'vm-subnet'

@description('Specifies the address prefix of the subnet which contains the virtual machine.')
param vmSubnetAddressPrefix string = '10.3.1.0/24'

@description('Specifies the Bastion subnet IP prefix. This prefix must be within vnet IP prefix address space.')
param bastionSubnetAddressPrefix string = '10.3.2.0/24'

@description('Specifies the name of the Log Analytics Workspace.')
param logAnalyticsWorkspaceName string = letterCaseType == 'UpperCamelCase'
  ? '${toUpper(first(prefix))}${toLower(substring(prefix, 1, length(prefix) - 1))}Workspace'
  : letterCaseType == 'CamelCase' ? '${toLower(prefix)}Workspace' : '${toLower(prefix)}-workspace'

@description('Specifies the service tier of the workspace: Free, Standalone, PerNode, Per-GB.')
@allowed([
  'Free'
  'Standalone'
  'PerNode'
  'PerGB2018'
])
param logAnalyticsSku string = 'PerNode'

@description('Specifies the workspace data retention in days. -1 means Unlimited retention for the Unlimited Sku. 730 days is the maximum allowed for all other Skus.')
param logAnalyticsRetentionInDays int = 60

@description('Specifies whether creating or not a jumpbox virtual machine in the AKS cluster virtual network.')
param vmEnabled bool = true

@description('Specifies the name of the virtual machine.')
param vmName string = 'TestVm'

@description('Specifies the size of the virtual machine.')
param vmSize string = 'Standard_DS3_v2'

@description('Specifies the image publisher of the disk image used to create the virtual machine.')
param imagePublisher string = 'Canonical'

@description('Specifies the offer of the platform image or marketplace image used to create the virtual machine.')
param imageOffer string = '0001-com-ubuntu-server-jammy'

@description('Specifies the Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version.')
param imageSku string = '22_04-lts-gen2'

@description('Specifies the type of authentication when accessing the Virtual Machine. SSH key is recommended.')
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'password'

@description('Specifies the name of the administrator account of the virtual machine.')
param vmAdminUsername string

@description('Specifies the SSH Key or password for the virtual machine. SSH key is recommended.')
@secure()
param vmAdminPasswordOrKey string

@description('Specifies the storage account type for OS and data disk.')
@allowed([
  'Premium_LRS'
  'StandardSSD_LRS'
  'Standard_LRS'
  'UltraSSD_LRS'
])
param diskStorageAccountType string = 'Premium_LRS'

@description('Specifies the number of data disks of the virtual machine.')
@minValue(0)
@maxValue(64)
param numDataDisks int = 1

@description('Specifies the size in GB of the OS disk of the VM.')
param osDiskSize int = 50

@description('Specifies the size in GB of the OS disk of the virtual machine.')
param dataDiskSize int = 50

@description('Specifies the caching requirements for the data disks.')
param dataDiskCaching string = 'ReadWrite'

@description('Specifies the globally unique name for the storage account used to store the boot diagnostics logs of the virtual machine.')
param blobStorageAccountName string = '${toLower(prefix)}${uniqueString(resourceGroup().id)}'

@description('Specifies the name of the private link to the boot diagnostics storage account.')
param blobStorageAccountPrivateEndpointName string = letterCaseType == 'UpperCamelCase'
  ? 'BlobStorageAccountPrivateEndpoint'
  : letterCaseType == 'CamelCase' ? 'blobStorageAccountPrivateEndpoint' : 'blob-storage-account-private-endpoint'

@description('Specifies the name of the private link to the Azure Container Registry.')
param acrPrivateEndpointName string = letterCaseType == 'UpperCamelCase'
  ? 'AcrPrivateEndpoint'
  : letterCaseType == 'CamelCase' ? 'acrPrivateEndpoint' : 'acr-private-endpoint'

@description('Name of your Azure Container Registry')
@minLength(5)
@maxLength(50)
param acrName string = letterCaseType == 'UpperCamelCase'
  ? '${toUpper(first(prefix))}${toLower(substring(prefix, 1, length(prefix) - 1))}Registry'
  : letterCaseType == 'CamelCase' ? '${toLower(prefix)}Registry' : '${toLower(prefix)}-Registry'

@description('Enable admin user that have push / pull permission to the registry.')
param acrAdminUserEnabled bool = false

@description('Tier of your Azure Container Registry.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string = 'Premium'

@description('Whether to allow public network access. Defaults to Enabled.')
@allowed([
  'Disabled'
  'Enabled'
])
param acrPublicNetworkAccess string = 'Disabled'

@description('Specifies whether or not registry-wide pull is enabled from unauthenticated clients.')
param acrAnonymousPullEnabled bool = true

@description('Specifies whether or not a single data endpoint is enabled per region for serving data.')
param acrDataEndpointEnabled bool = true

@description('Specifies the network rule set for the container registry.')
param acrNetworkRuleSet object = {
  defaultAction: 'Allow'
}

@description('Specifies ehether to allow trusted Azure services to access a network restricted registry.')
@allowed([
  'AzureServices'
  'None'
])
param acrNetworkRuleBypassOptions string = 'AzureServices'

@description('Specifies whether or not zone redundancy is enabled for this container registry.')
@allowed([
  'Disabled'
  'Enabled'
])
param acrZoneRedundancy string = 'Enabled'

@description('Specifies whether Azure Bastion should be created.')
param bastionHostEnabled bool = true

@description('Specifies the name of the Azure Bastion resource.')
param bastionHostName string = letterCaseType == 'UpperCamelCase'
  ? '${toUpper(first(prefix))}${toLower(substring(prefix, 1, length(prefix) - 1))}Bastion'
  : letterCaseType == 'CamelCase' ? '${toLower(prefix)}Bastion' : '${toLower(prefix)}-bastion'

@description('Specifies the name of the Application Gateway.')
param applicationGatewayName string = letterCaseType == 'UpperCamelCase'
  ? '${toUpper(first(prefix))}${toLower(substring(prefix, 1, length(prefix) - 1))}ApplicationGateway'
  : letterCaseType == 'CamelCase' ? '${toLower(prefix)}ApplicationGateway' : '${toLower(prefix)}-application-gateway'

@description('Specifies the sku of the Application Gateway.')
param applicationGatewaySkuName string = 'WAF_v2'

@description('Specifies the private IP address of the Application Gateway.')
param applicationGatewayPrivateIpAddress string = ''

@description('Specifies the frontend IP configuration type.')
@allowed([
  'Public'
  'Private'
  'Both'
])
param applicationGatewayFrontendIpConfigurationType string = 'Public'

@description('Specifies the name of the public IP adddress used by the Application Gateway.')
param applicationGatewayPublicIpAddressName string = '${applicationGatewayName}PublicIp'

@description('Specifies the availability zones of the Application Gateway.')
param applicationGatewayAvailabilityZones array = [
  '1'
  '2'
  '3'
]

@description('Specifies the lower bound on number of Application Gateway capacity.')
param applicationGatewayMinCapacity int = 1

@description('Specifies the upper bound on number of Application Gateway capacity.')
param applicationGatewayMaxCapacity int = 10

@description('Specifies the backend address pool name of the Application Gateway')
param backendAddressPoolName string = 'DefaultBackendAddressPool'

@description('Specifies an array containing trusted root certificates.')
@metadata({
  name: 'Certificate name'
  keyVaultSecretId: 'Key Vault Secret resouce id'
})
param trustedRootCertificates array = []

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

@description('Specifies the name of the WAF policy')
param wafPolicyName string = '${applicationGatewayName}WafPolicy'

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

@description('Specifies the name of the Azure NAT Gateway.')
param natGatewayName string = letterCaseType == 'UpperCamelCase'
  ? '${toUpper(first(prefix))}${toLower(substring(prefix, 1, length(prefix) - 1))}NatGateway'
  : letterCaseType == 'CamelCase' ? '${toLower(prefix)}NatGateway' : '${toLower(prefix)}-nat-gateway'

@description('Specifies a list of availability zones denoting the zone in which Nat Gateway should be deployed.')
param natGatewayZones array = []

@description('Specifies the number of Public IPs to create for the Azure NAT Gateway.')
param natGatewayPublicIps int = 1

@description('Specifies the idle timeout in minutes for the Azure NAT Gateway.')
param natGatewayIdleTimeoutMins int = 30

@description('Specifies the name of the private link to the Key Vault.')
param keyVaultPrivateEndpointName string = letterCaseType == 'UpperCamelCase'
  ? 'KeyVaultPrivateEndpoint'
  : letterCaseType == 'CamelCase' ? 'keyVaultPrivateEndpoint' : 'key-vault-private-endpoint'

@description('Specifies the name of an existing Key Vault resource holding the TLS certificate.')
param keyVaultName string

@description('Specifies the name of the resource group that contains the existing Key Vault resource.')
param keyVaultResourceGroupName string

@description('Specifies the resource tags.')
param tags object = {
  IaC: 'Bicep'
}

@description('Specifies the resource tags.')
param clusterTags object = {
  IaC: 'Bicep'
  ApiServerVnetIntegration: true
}

@description('Specifies the name of the Action Group.')
param actionGroupName string = letterCaseType == 'UpperCamelCase'
  ? '${toUpper(first(prefix))}${toLower(substring(prefix, 1, length(prefix) - 1))}ActionGroup'
  : letterCaseType == 'CamelCase' ? '${toLower(prefix)}ActionGroup' : '${toLower(prefix)}-action-group'

@description('Specifies the short name of the action group. This will be used in SMS messages..')
param actionGroupShortName string = 'AksAlerts'

@description('Specifies whether this action group is enabled. If an action group is not enabled, then none of its receivers will receive communications.')
param actionGroupEnabled bool = true

@description('Specifies the email address of the receiver.')
param actionGroupEmailAddress string

@description('Specifies whether to use common alert schema..')
param actionGroupUseCommonAlertSchema bool = false

@description('Specifies the country code of the SMS receiver.')
param actionGroupCountryCode string = '39'

@description('Specifies the phone number of the SMS receiver.')
param actionGroupPhoneNumber string = ''

@description('Specifies a comma-separated list of additional Kubernetes label keys that will be used in the resource labels metric.')
param metricAnnotationsAllowList string = ''

@description('Specifies a comma-separated list of Kubernetes annotations keys that will be used in the resource labels metric.')
param metricLabelsAllowlist string = ''

@description('Specifies the name of the Azure Monitor managed service for Prometheus resource.')
param prometheusName string = letterCaseType == 'UpperCamelCase'
  ? '${toUpper(first(prefix))}${toLower(substring(prefix, 1, length(prefix) - 1))}Prometheus'
  : letterCaseType == 'CamelCase' ? '${toLower(prefix)}Prometheus' : '${toLower(prefix)}-prometheus'

@description('Specifies whether or not public endpoint access is allowed for the Azure Monitor managed service for Prometheus resource.')
@allowed([
  'Enabled'
  'Disabled'
])
param prometheusPublicNetworkAccess string = 'Enabled'

@description('Specifies the name of the Azure Managed Grafana resource.')
param grafanaName string = letterCaseType == 'UpperCamelCase'
  ? '${toUpper(first(prefix))}${toLower(substring(prefix, 1, length(prefix) - 1))}Grafana'
  : letterCaseType == 'CamelCase' ? '${toLower(prefix)}Grafana' : '${toLower(prefix)}-grafana'

@description('Specifies the sku of the Azure Managed Grafana resource.')
param grafanaSkuName string = 'Standard'

@description('Specifies the api key setting of the Azure Managed Grafana resource.')
@allowed([
  'Disabled'
  'Enabled'
])
param grafanaApiKey string = 'Enabled'

@description('Specifies the scope for dns deterministic name hash calculation.')
@allowed([
  'TenantReuse'
])
param grafanaAutoGeneratedDomainNameLabelScope string = 'TenantReuse'

@description('Specifies whether the Azure Managed Grafana resource uses deterministic outbound IPs.')
@allowed([
  'Disabled'
  'Enabled'
])
param grafanaDeterministicOutboundIP string = 'Disabled'

@description('Specifies the the state for enable or disable traffic over the public interface for the the Azure Managed Grafana resource.')
@allowed([
  'Disabled'
  'Enabled'
])
param grafanaPublicNetworkAccess string = 'Enabled'

@description('The zone redundancy setting of the Azure Managed Grafana resource.')
@allowed([
  'Disabled'
  'Enabled'
])
param grafanaZoneRedundancy string = 'Disabled'

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

@description('Specifies the name of the deployment script uri.')
param deploymentScripName string = letterCaseType == 'UpperCamelCase'
  ? '${toUpper(first(prefix))}${toLower(substring(prefix, 1, length(prefix) - 1))}BashScript'
  : letterCaseType == 'CamelCase' ? '${toLower(prefix)}BashScript' : '${toLower(prefix)}-bash-script'

@description('Specifies the uri of the deployment script.')
param deploymentScriptUri string

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

@description('Specifies the name of an existing public DNS zone.')
param dnsZoneName string

@description('Specifies the name of the resource group which contains the public DNS zone.')
param dnsZoneResourceGroupName string

@description('Specifies the name of the Key Vault certificate.')
param keyVaultCertificateName string

// Variables
var loadBalancerName = 'kubernetes-internal'

// Modules
module keyVault 'keyVault.bicep' = {
  name: 'keyVault'
  scope: resourceGroup(keyVaultResourceGroupName)
  params: {
    name: keyVaultName
    aksManagedIdentityObjectId: aksCluster.outputs.azureKeyvaultSecretsProviderIdentity.objectId
    applicationGatewayManagedIdentityPrincipalId: applicationGatewayManageIdentity.outputs.principalId
    azureKeyvaultSecretsProviderEnabled: azureKeyvaultSecretsProviderEnabled
  }
}

module workspace 'logAnalytics.bicep' = {
  name: 'workspace'
  params: {
    name: logAnalyticsWorkspaceName
    location: location
    sku: logAnalyticsSku
    retentionInDays: logAnalyticsRetentionInDays
    tags: tags
  }
}

module containerRegistry 'containerRegistry.bicep' = {
  name: 'containerRegistry'
  params: {
    name: acrName
    sku: acrSku
    adminUserEnabled: acrAdminUserEnabled
    anonymousPullEnabled: acrAnonymousPullEnabled
    dataEndpointEnabled: acrDataEndpointEnabled
    networkRuleBypassOptions: acrNetworkRuleBypassOptions
    networkRuleSet: acrNetworkRuleSet
    publicNetworkAccess: acrPublicNetworkAccess
    zoneRedundancy: acrZoneRedundancy
    workspaceId: workspace.outputs.id
    location: location
    tags: tags
  }
}

module storageAccount 'storageAccount.bicep' = {
  name: 'storageAccount'
  params: {
    name: blobStorageAccountName
    createContainers: false
    containerNames: []
    workspaceId: workspace.outputs.id
    location: location
    tags: tags
  }
}
resource existingKeyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
  scope: resourceGroup(keyVaultResourceGroupName)
}

module network 'network.bicep' = {
  name: 'network'
  params: {
    podSubnetEnabled: aksClusterNetworkPluginMode != 'overlay' && podSubnetName != '' && podSubnetAddressPrefix != ''
    enableVnetIntegration: enableVnetIntegration
    bastionHostEnabled: bastionHostEnabled
    virtualNetworkName: virtualNetworkName
    virtualNetworkAddressPrefixes: virtualNetworkAddressPrefixes
    systemAgentPoolSubnetName: systemAgentPoolSubnetName
    systemAgentPoolSubnetAddressPrefix: systemAgentPoolSubnetAddressPrefix
    userAgentPoolSubnetName: userAgentPoolSubnetName
    userAgentPoolSubnetAddressPrefix: userAgentPoolSubnetAddressPrefix
    podSubnetName: podSubnetName
    podSubnetAddressPrefix: podSubnetAddressPrefix
    apiServerSubnetName: apiServerSubnetName
    apiServerSubnetAddressPrefix: apiServerSubnetAddressPrefix
    vmSubnetName: vmSubnetName
    vmSubnetAddressPrefix: vmSubnetAddressPrefix
    vmSubnetNsgName: letterCaseType == 'UpperCamelCase'
      ? '${toUpper(first(vmSubnetName))}${substring(vmSubnetName, 1, length(vmSubnetName) - 1)}Nsg'
      : letterCaseType == 'CamelCase'
          ? '${toLower(first(vmSubnetName))}${substring(vmSubnetName, 1, length(vmSubnetName) - 1)}Nsg'
          : '${toLower(vmSubnetName)}-nsg'
    bastionSubnetAddressPrefix: bastionSubnetAddressPrefix
    bastionSubnetNsgName: letterCaseType == 'UpperCamelCase'
      ? 'AzureBastionSubnetNsg'
      : letterCaseType == 'CamelCase' ? 'azureBastionSubnetNsg' : 'azure-bastion-nsg'
    applicationGatewaySubnetName: applicationGatewaySubnetName
    applicationGatewaySubnetAddressPrefix: applicationGatewaySubnetAddressPrefix
    bastionHostName: bastionHostName
    natGatewayName: natGatewayName
    natGatewayEnabled: aksClusterOutboundType == 'userAssignedNATGateway'
    natGatewayZones: natGatewayZones
    natGatewayPublicIps: natGatewayPublicIps
    natGatewayIdleTimeoutMins: natGatewayIdleTimeoutMins
    createAcrPrivateEndpoint: acrSku == 'Premium'
    storageAccountPrivateEndpointName: blobStorageAccountPrivateEndpointName
    storageAccountId: storageAccount.outputs.id
    keyVaultPrivateEndpointName: keyVaultPrivateEndpointName
    keyVaultId: existingKeyVault.id
    acrPrivateEndpointName: acrPrivateEndpointName
    acrId: containerRegistry.outputs.id
    workspaceId: workspace.outputs.id
    location: location
    tags: tags
  }
}

module internalLoadbalancer 'internalLoadBalancer.bicep' = {
  name: 'internalLoadBalancer'
  params: {
    name: loadBalancerName
    resourceGroupName: aksCluster.outputs.nodeResourceGroup
  }
  dependsOn: [
    deploymentScript
  ]
}

module applicationGatewayManageIdentity 'applicationGatewayIdentity.bicep' = {
  name: 'applicationGatewayManageIdentity'
  params: {
    managedIdentityName: letterCaseType == 'UpperCamelCase' || letterCaseType == 'CamelCase'
      ? '${applicationGatewayName}Identity'
      : '${applicationGatewayName}-identity'
    location: location
    tags: tags
  }
}

module applicationGateway 'applicationGateway.bicep' = {
  name: 'applicationGateway'
  params: {
    name: applicationGatewayName
    managedIdentityId: applicationGatewayManageIdentity.outputs.id
    skuName: applicationGatewaySkuName
    frontendIpConfigurationType: applicationGatewayFrontendIpConfigurationType
    publicIpAddressName: applicationGatewayPublicIpAddressName
    subnetId: network.outputs.applicationGatewaySubnetId
    privateIpAddress: applicationGatewayPrivateIpAddress
    availabilityZones: applicationGatewayAvailabilityZones
    minCapacity: applicationGatewayMinCapacity
    maxCapacity: applicationGatewayMaxCapacity
    trustedRootCertificates: trustedRootCertificates
    sslCertificates: [
      {
        name: keyVaultCertificateName
        keyVaultSecretId: '${keyVault.outputs.vaultUri}secrets/${keyVaultCertificateName}'
      }
    ]
    frontendPorts: frontendPorts
    probes: probes
    backendAddressPools: [
      {
        name: backendAddressPoolName
        backendAddresses: [
          {
            ipAddress: internalLoadbalancer.outputs.privateIpAddress
          }
        ]
      }
    ]
    backendHttpSettings: backendHttpSettings
    httpListeners: httpListeners
    requestRoutingRules: requestRoutingRules
    redirectConfigurations: redirectConfigurations
    wafPolicyName: wafPolicyName
    wafPolicyMode: wafPolicyMode
    wafPolicyState: wafPolicyState
    wafPolicyFileUploadLimitInMb: wafPolicyFileUploadLimitInMb
    wafPolicyMaxRequestBodySizeInKb: wafPolicyMaxRequestBodySizeInKb
    wafPolicyRequestBodyCheck: wafPolicyRequestBodyCheck
    wafPolicyRuleSetType: wafPolicyRuleSetType
    wafPolicyRuleSetVersion: wafPolicyRuleSetVersion
    workspaceId: workspace.outputs.id
    location: location
    tags: clusterTags
  }
}

module jumpboxVirtualMachine 'virtualMachine.bicep' = if (vmEnabled) {
  name: 'jumpboxVirtualMachine'
  params: {
    vmName: vmName
    vmSize: vmSize
    vmSubnetId: network.outputs.vmSubnetId
    storageAccountName: vmEnabled ? storageAccount.outputs.name : ''
    imagePublisher: imagePublisher
    imageOffer: imageOffer
    imageSku: imageSku
    authenticationType: authenticationType
    vmAdminUsername: vmAdminUsername
    vmAdminPasswordOrKey: vmAdminPasswordOrKey
    diskStorageAccountType: diskStorageAccountType
    numDataDisks: numDataDisks
    osDiskSize: osDiskSize
    dataDiskSize: dataDiskSize
    dataDiskCaching: dataDiskCaching
    managedIdentityName: letterCaseType == 'UpperCamelCase'
      ? '${toUpper(first(prefix))}${toLower(substring(prefix, 1, length(prefix) - 1))}AzureMonitorAgentManagedIdentity'
      : letterCaseType == 'CamelCase'
          ? '${toLower(prefix)}AzureMonitorAgentManagedIdentity'
          : '${toLower(prefix)}-azure-monitor-agent-managed-identity'
    location: location
    tags: tags
  }
}

module aksManageIdentity 'aksManagedIdentity.bicep' = {
  name: 'aksManageIdentity'
  params: {
    managedIdentityName: letterCaseType == 'UpperCamelCase' || letterCaseType == 'CamelCase'
      ? '${aksClusterName}Identity'
      : '${aksClusterName}-identity'
    virtualNetworkName: network.outputs.virtualNetworkName
    location: location
    tags: tags
  }
}

module kubeletManageIdentity 'kubeletManagedIdentity.bicep' = {
  name: 'kubeletManageIdentity'
  params: {
    aksClusterName: aksCluster.outputs.name
    acrName: containerRegistry.outputs.name
  }
  dependsOn: [
    aksCluster
  ]
}

module aksCluster 'aksCluster.bicep' = {
  name: 'aksCluster'
  params: {
    name: aksClusterName
    enableVnetIntegration: enableVnetIntegration
    virtualNetworkName: network.outputs.virtualNetworkName
    systemAgentPoolSubnetName: systemAgentPoolSubnetName
    userAgentPoolSubnetName: userAgentPoolSubnetName
    podSubnetName: podSubnetName
    apiServerSubnetName: apiServerSubnetName
    managedIdentityName: aksManageIdentity.outputs.name
    dnsPrefix: aksClusterDnsPrefix
    networkDataplane: aksClusterNetworkDataplane
    networkMode: aksClusterNetworkMode
    networkPlugin: aksClusterNetworkPlugin
    networkPluginMode: aksClusterNetworkPluginMode
    networkPolicy: aksClusterNetworkPolicy
    webAppRoutingEnabled: aksClusterWebAppRoutingEnabled
    nginxDefaultIngressControllerType: aksClusterNginxDefaultIngressControllerType
    podCidr: aksClusterPodCidr
    serviceCidr: aksClusterServiceCidr
    dnsServiceIP: aksClusterDnsServiceIP
    loadBalancerSku: aksClusterLoadBalancerSku
    loadBalancerBackendPoolType: loadBalancerBackendPoolType
    advancedNetworking: advancedNetworking
    ipFamilies: aksClusterIpFamilies
    outboundType: aksClusterOutboundType
    skuTier: aksClusterSkuTier
    kubernetesVersion: aksClusterKubernetesVersion
    adminUsername: aksClusterAdminUsername
    sshPublicKey: aksClusterSshPublicKey
    aadProfileTenantId: aadProfileTenantId
    aadProfileAdminGroupObjectIDs: aadProfileAdminGroupObjectIDs
    aadProfileManaged: aadProfileManaged
    aadProfileEnableAzureRBAC: aadProfileEnableAzureRBAC
    nodeOSUpgradeChannel: aksClusterNodeOSUpgradeChannel
    upgradeChannel: aksClusterUpgradeChannel
    enablePrivateCluster: aksClusterEnablePrivateCluster
    privateDNSZone: aksPrivateDNSZone
    enablePrivateClusterPublicFQDN: aksEnablePrivateClusterPublicFQDN
    systemAgentPoolName: systemAgentPoolName
    systemAgentPoolVmSize: systemAgentPoolVmSize
    systemAgentPoolOsDiskSizeGB: systemAgentPoolOsDiskSizeGB
    systemAgentPoolOsDiskType: systemAgentPoolOsDiskType
    systemAgentPoolAgentCount: systemAgentPoolAgentCount
    systemAgentPoolOsSKU: systemAgentPoolOsSKU
    systemAgentPoolOsType: systemAgentPoolOsType
    systemAgentPoolMaxPods: systemAgentPoolMaxPods
    systemAgentPoolMaxCount: systemAgentPoolMaxCount
    systemAgentPoolMinCount: systemAgentPoolMinCount
    systemAgentPoolEnableAutoScaling: systemAgentPoolEnableAutoScaling
    systemAgentPoolScaleSetPriority: systemAgentPoolScaleSetPriority
    systemAgentPoolScaleSetEvictionPolicy: systemAgentPoolScaleSetEvictionPolicy
    systemAgentPoolNodeLabels: systemAgentPoolNodeLabels
    systemAgentPoolNodeTaints: systemAgentPoolNodeTaints
    systemAgentPoolType: systemAgentPoolType
    systemAgentPoolAvailabilityZones: systemAgentPoolAvailabilityZones
    systemAgentPoolKubeletDiskType: systemAgentPoolKubeletDiskType
    userAgentPoolName: userAgentPoolName
    userAgentPoolVmSize: userAgentPoolVmSize
    userAgentPoolOsDiskSizeGB: userAgentPoolOsDiskSizeGB
    userAgentPoolOsDiskType: userAgentPoolOsDiskType
    userAgentPoolAgentCount: userAgentPoolAgentCount
    userAgentPoolOsSKU: userAgentPoolOsSKU
    userAgentPoolOsType: userAgentPoolOsType
    userAgentPoolMaxPods: userAgentPoolMaxPods
    userAgentPoolMaxCount: userAgentPoolMaxCount
    userAgentPoolMinCount: userAgentPoolMinCount
    userAgentPoolEnableAutoScaling: userAgentPoolEnableAutoScaling
    userAgentPoolScaleSetPriority: userAgentPoolScaleSetPriority
    userAgentPoolScaleSetEvictionPolicy: userAgentPoolScaleSetEvictionPolicy
    userAgentPoolNodeLabels: userAgentPoolNodeLabels
    userAgentPoolNodeTaints: userAgentPoolNodeTaints
    userAgentPoolType: userAgentPoolType
    userAgentPoolAvailabilityZones: userAgentPoolAvailabilityZones
    userAgentPoolKubeletDiskType: userAgentPoolKubeletDiskType
    httpApplicationRoutingEnabled: httpApplicationRoutingEnabled
    istioServiceMeshEnabled: istioServiceMeshEnabled
    istioIngressGatewayEnabled: istioIngressGatewayEnabled
    istioIngressGatewayType: istioIngressGatewayType
    kedaEnabled: kedaEnabled
    daprEnabled: daprEnabled
    daprHaEnabled: daprHaEnabled
    fluxGitOpsEnabled: fluxGitOpsEnabled
    verticalPodAutoscalerEnabled: verticalPodAutoscalerEnabled
    aciConnectorLinuxEnabled: aciConnectorLinuxEnabled
    azurePolicyEnabled: azurePolicyEnabled
    azureKeyvaultSecretsProviderEnabled: azureKeyvaultSecretsProviderEnabled
    kubeDashboardEnabled: kubeDashboardEnabled
    autoScalerProfileScanInterval: autoScalerProfileScanInterval
    autoScalerProfileScaleDownDelayAfterAdd: autoScalerProfileScaleDownDelayAfterAdd
    autoScalerProfileScaleDownDelayAfterDelete: autoScalerProfileScaleDownDelayAfterDelete
    autoScalerProfileScaleDownDelayAfterFailure: autoScalerProfileScaleDownDelayAfterFailure
    autoScalerProfileScaleDownUnneededTime: autoScalerProfileScaleDownUnneededTime
    autoScalerProfileScaleDownUnreadyTime: autoScalerProfileScaleDownUnreadyTime
    autoScalerProfileUtilizationThreshold: autoScalerProfileUtilizationThreshold
    autoScalerProfileMaxGracefulTerminationSec: autoScalerProfileMaxGracefulTerminationSec
    blobCSIDriverEnabled: blobCSIDriverEnabled
    diskCSIDriverEnabled: diskCSIDriverEnabled
    fileCSIDriverEnabled: fileCSIDriverEnabled
    snapshotControllerEnabled: snapshotControllerEnabled
    defenderSecurityMonitoringEnabled: defenderSecurityMonitoringEnabled
    imageCleanerEnabled: imageCleanerEnabled
    imageCleanerIntervalHours: imageCleanerIntervalHours
    nodeRestrictionEnabled: nodeRestrictionEnabled
    workloadIdentityEnabled: workloadIdentityEnabled
    oidcIssuerProfileEnabled: oidcIssuerProfileEnabled
    podIdentityProfileEnabled: podIdentityProfileEnabled
    prometheusAndGrafanaEnabled: true
    metricAnnotationsAllowList: metricAnnotationsAllowList
    metricLabelsAllowlist: metricLabelsAllowlist
    dnsZoneName: dnsZoneName
    dnsZoneResourceGroupName: dnsZoneResourceGroupName
    workspaceId: workspace.outputs.id
    userId: userId
    location: location
    tags: clusterTags
  }
  dependsOn: [
    network
    aksManageIdentity
    workspace
  ]
}

module actionGroup 'actionGroup.bicep' = if (actionGroupEnabled) {
  name: 'actionGroup'
  params: {
    name: actionGroupName
    enabled: actionGroupEnabled
    groupShortName: actionGroupShortName
    emailAddress: actionGroupEmailAddress
    useCommonAlertSchema: actionGroupUseCommonAlertSchema
    countryCode: actionGroupCountryCode
    phoneNumber: actionGroupPhoneNumber
    tags: tags
  }
}

module prometheus 'managedPrometheus.bicep' = {
  name: 'managedPrometheus'
  params: {
    name: prometheusName
    publicNetworkAccess: prometheusPublicNetworkAccess
    location: location
    tags: tags
    clusterName: aksCluster.outputs.name
    actionGroupId: actionGroupEnabled ? actionGroup.outputs.id : ''
  }
}

module grafana 'managedGrafana.bicep' = {
  name: 'managedGrafana'
  params: {
    name: grafanaName
    skuName: grafanaSkuName
    apiKey: grafanaApiKey
    autoGeneratedDomainNameLabelScope: grafanaAutoGeneratedDomainNameLabelScope
    deterministicOutboundIP: grafanaDeterministicOutboundIP
    publicNetworkAccess: grafanaPublicNetworkAccess
    zoneRedundancy: grafanaZoneRedundancy
    prometheusName: prometheus.outputs.name
    userId: userId
    location: location
    tags: tags
  }
}

module aksmetricalerts 'metricAlerts.bicep' = if (createMetricAlerts) {
  name: 'aksmetricalerts'
  scope: resourceGroup()
  params: {
    aksClusterName: aksCluster.outputs.name
    metricAlertsEnabled: metricAlertsEnabled
    evalFrequency: metricAlertsEvalFrequency
    windowSize: metricAlertsWindowsSize
    alertSeverity: 'Informational'
    tags: tags
  }
  dependsOn: [
    aksCluster
  ]
}

module deploymentScript 'deploymentScript.bicep' = {
  name: 'deploymentScript'
  params: {
    name: deploymentScripName
    managedIdentityName: letterCaseType == 'UpperCamelCase' || letterCaseType == 'CamelCase'
      ? '${deploymentScripName}Identity'
      : '${deploymentScripName}-identity'
    primaryScriptUri: deploymentScriptUri
    azCliVersion: azCliVersion
    retentionInterval: retentionInterval
    cleanupPreference: cleanupPreference
    timeout: timeout
    clusterName: aksCluster.outputs.name
    resourceGroupName: resourceGroup().name
    subscriptionId: subscription().subscriptionId
    deployPrometheusAndGrafanaViaHelm: deployPrometheusAndGrafanaViaHelm
    deployCertificateManagerViaHelm: deployCertificateManagerViaHelm
    ingressClassNames: ingressClassNames
    clusterIssuerNames: clusterIssuerNames
    deployNginxIngressControllerViaHelm: deployNginxIngressControllerViaHelm
    email: email
    location: location
    tags: tags
  }
  dependsOn: [
    aksCluster
  ]
}

// Outputs
output aksClusterName string = aksCluster.outputs.name
output aksClusterFqdn string = aksCluster.outputs.fqdn
output acrName string = containerRegistry.outputs.name
output keyVaultName string = keyVault.outputs.name
output logAnalyticsWorkspaceName string = workspace.outputs.name
