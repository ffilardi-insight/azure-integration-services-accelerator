param name string
param location string = resourceGroup().location
param tags object = {}
param kind string = 'ASEV3'
param subnetId string
param networkResourceGroupName string
param privateDnsZoneName string
param dedicatedHostCount int = 0
param zoneRedundant bool = false
param internalLoadBalancingMode string = 'Web, Publishing'
param disableTls10 bool = true
param allowNewPrivateEndpointConnections bool = true
param ftpEnabled bool = true
param remoteDebugEnabled bool = true
param enableLogs bool = true
param logAnalyticsWorkspaceId string = ''

resource ase 'Microsoft.Web/hostingEnvironments@2022-09-01' = {
  name: name
  location: location
  tags: union(tags, { 'azd-service-name': name })
  kind: kind
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    zoneRedundant: zoneRedundant
    dedicatedHostCount: dedicatedHostCount
    internalLoadBalancingMode: internalLoadBalancingMode
    virtualNetwork: {
      id: subnetId
    }
    networkingConfiguration: {
      properties: {
        allowNewPrivateEndpointConnections: allowNewPrivateEndpointConnections
        ftpEnabled: ftpEnabled
        remoteDebugEnabled: remoteDebugEnabled
      }  
    }
    clusterSettings: [
      {
        name: 'DisableTls1.0'
        value: disableTls10 ? '1' : '0'
      }
    ]
  }

  resource networking 'configurations' existing = {
    name: 'networking'
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticsettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: 'Logging'
  scope: ase
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
        {
          category: 'AppServiceEnvironmentPlatformLogs'
          categoryGroup: null
          enabled: enableLogs
      }
    ]
  }
}

module dnsConfig './ase-dns-config.bicep' = {
  name: 'ase-dns-config'
  scope: resourceGroup(networkResourceGroupName)
  params: {
    privateDnsZoneName: privateDnsZoneName
    aseInboundIpv4Address: ase::networking.properties.internalInboundIpAddresses[0]
  }
}

output aseId string = ase.id
output aseName string = ase.name
output aseUrl string = ase.properties.dnsSuffix
