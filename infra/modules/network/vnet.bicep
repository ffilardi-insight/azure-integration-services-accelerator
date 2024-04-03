param name string
param location string = resourceGroup().location
param tags object = {}
param logAnalyticsWorkspaceId string = ''
param enableLogs bool = true
param enableMetrics bool = true
param vnetAddressPrefixes array = ['10.0.0.0/16']
param subnetDefaultAddressPrefix string = '10.0.0.0/24'
param subnetPEAddressPrefix string = '10.0.1.0/24'
param subnetAPIMAddressPrefix string = '10.0.2.0/24'
param subnetAppAddressPrefix string = '10.0.3.0/24'
param privateEndpointNsgId string
param privateEndpointSubnetName string
param apimNsgId string
param apimSubnetName string
param appNsgId string
param appSubnetName string
param deployAse bool = false

var subnets = [
  {
    name: 'default'
    properties: {
      addressPrefix: subnetDefaultAddressPrefix
    }
  }
  {
    name: privateEndpointSubnetName
    properties: {
      addressPrefix: subnetPEAddressPrefix
      networkSecurityGroup: privateEndpointNsgId == '' ? null : {
        id: privateEndpointNsgId
      }
    }
  }
  {
    name: apimSubnetName
    properties: {
      addressPrefix: subnetAPIMAddressPrefix
      networkSecurityGroup: apimNsgId == '' ? null : {
        id: apimNsgId
      }
    }
  }
  {
    name: appSubnetName
    properties: {
      addressPrefix: subnetAppAddressPrefix
      delegations: [
        {
          name: deployAse ? 'Microsoft.Web/hostingEnvironments' : 'Microsoft.Web/serverfarms'
          properties: {
            serviceName: deployAse ? 'Microsoft.Web/hostingEnvironments' : 'Microsoft.Web/serverfarms'
          }
        }
      ]
      serviceEndpoints: [
        {
          service: 'Microsoft.Storage'
        }
      ]
      networkSecurityGroup: appNsgId == '' ? null : {
        id: appNsgId
      }
      privateEndpointNetworkPolicies: 'Disabled'
      privateLinkServiceNetworkPolicies: 'Disabled'
    }
  }
]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: name
  location: location
  tags: union(tags, { 'azd-service-name': name })
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressPrefixes
    }
    subnets: subnets
  }

  resource defaultSubnet 'subnets' existing = {
    name: 'default'
  }

  resource privateEndpointSubnet 'subnets' existing = {
    name: privateEndpointSubnetName
  }

  resource apimSubnet 'subnets' existing = {
    name: apimSubnetName
  }

  resource appSubnet 'subnets' existing = {
    name: appSubnetName
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticsettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: 'Logging'
  scope: virtualNetwork
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
        {
          category: null
          categoryGroup: 'allLogs'
          enabled: enableLogs
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: enableMetrics
      }
    ]
  }
}

output vnetId string = virtualNetwork.id
output vnetName string = virtualNetwork.name
output privateEndpointSubnetId string = virtualNetwork::privateEndpointSubnet.id
output privateEndpointSubnetName string = virtualNetwork::privateEndpointSubnet.name
output apimSubnetId string = virtualNetwork::apimSubnet.id
output appSubnetId string = virtualNetwork::appSubnet.id
