param vnetName string
param location string = resourceGroup().location
param tags object = {}
param logAnalyticsWorkspaceId string = ''
param privateEndpointNsgName string
param privateEndpointSubnetName string
param apimNsgName string
param apimSubnetName string
param appSubnetName string
param appNsgName string
param privateDnsZoneNames array
param deployAse bool = false

module networkSecurityGroups './nsg.bicep' = {
  name: 'nsg'
  scope: resourceGroup()
  params: {
    location: location
    tags: tags
    privateEndpointNsgName: privateEndpointNsgName
    apimNsgName: apimNsgName
    appNsgName: appNsgName
  }
}

module virtualNetwork './vnet.bicep' = {
  name: 'vnet'
  scope: resourceGroup()
  params: {
    name: vnetName
    location: location
    tags: tags
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    privateEndpointNsgId: networkSecurityGroups.outputs.privateEndpointNsgId
    privateEndpointSubnetName: privateEndpointSubnetName
    apimNsgId: networkSecurityGroups.outputs.apimNsgId
    apimSubnetName: apimSubnetName
    appNsgId: networkSecurityGroups.outputs.appNsgId
    appSubnetName: appSubnetName
    deployAse: deployAse
  }
}

module privateDnsZones './private-dns.bicep' = [for privateDnsZoneName in privateDnsZoneNames: {
  name: 'private-dns-${privateDnsZoneName}'
  scope: resourceGroup()
  params: {
    name: privateDnsZoneName
    vnetId: virtualNetwork.outputs.vnetId
  }
}]

output virtualNetworkId string = virtualNetwork.outputs.vnetId
output vnetName string = virtualNetwork.outputs.vnetName
output privateEndpointSubnetId string = virtualNetwork.outputs.privateEndpointSubnetId
output privateEndpointSubnetName string = virtualNetwork.outputs.privateEndpointSubnetName
output apimSubnetId string = virtualNetwork.outputs.apimSubnetId
output appSubnetId string = virtualNetwork.outputs.appSubnetId
