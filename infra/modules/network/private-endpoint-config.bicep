param environmentName string
param resourceToken string
param location string = resourceGroup().location
param vnetName string
param privateEndpointSubnetName string
param privateDnsZones object
param serviceIds object

var abbrs = loadJsonContent('../../abbreviations.json')

module monitorPrivateEndpoint './private-endpoint.bicep' = {
  name: 'monitor-privateEndpoint-deployment'
  scope: resourceGroup()
  params: {
    name: '${abbrs.insightsComponents}${abbrs.privateEndpoints}${environmentName}-${resourceToken}'
    location: location
    vnetName: vnetName
    subnetName: privateEndpointSubnetName
    dnsZoneName: privateDnsZones.privateLinkPrivateDnsZoneName
    serviceId: serviceIds.privateLinkScopeId
    groupIds: ['azuremonitor']
  }
}

module keyVaultPrivateEndpoint './private-endpoint.bicep' = {
  name: 'keyvault-privateEndpoint-deployment'
  scope: resourceGroup()
  params: {
    name: '${abbrs.keyVaultVaults}${abbrs.privateEndpoints}${environmentName}-${resourceToken}'
    location: location
    vnetName: vnetName
    subnetName: privateEndpointSubnetName
    dnsZoneName: privateDnsZones.keyVaultPrivateDnsZoneName
    serviceId: serviceIds.keyVaultId
    groupIds: ['vault']
  }
}

module storageBlobPrivateEndpoint './private-endpoint.bicep' = {
  name: 'storage-blob-privateEndpoint-deployment'
  scope: resourceGroup()
  params: {
    name: '${abbrs.storageStorageAccounts}-blob-${abbrs.privateEndpoints}${environmentName}-${resourceToken}'
    location: location
    vnetName: vnetName
    subnetName: privateEndpointSubnetName
    dnsZoneName: privateDnsZones.storageBlobPrivateDnsZoneName
    serviceId: serviceIds.storageAccountId
    groupIds: ['blob']
  }
}

module storageFilePrivateEndpoint './private-endpoint.bicep' = {
  name: 'storage-file-privateEndpoint-deployment'
  scope: resourceGroup()
  params: {
    name: '${abbrs.storageStorageAccounts}-file-${abbrs.privateEndpoints}${environmentName}-${resourceToken}'
    location: location
    vnetName: vnetName
    subnetName: privateEndpointSubnetName
    dnsZoneName: privateDnsZones.storageFilePrivateDnsZoneName
    serviceId: serviceIds.storageAccountId
    groupIds: ['file']
  }
}

module storageTablePrivateEndpoint './private-endpoint.bicep' = {
  name: 'storage-table-privateEndpoint-deployment'
  scope: resourceGroup()
  params: {
    name: '${abbrs.storageStorageAccounts}-table-${abbrs.privateEndpoints}${environmentName}-${resourceToken}'
    location: location
    vnetName: vnetName
    subnetName: privateEndpointSubnetName
    dnsZoneName: privateDnsZones.storageTablePrivateDnsZoneName
    serviceId: serviceIds.storageAccountId
    groupIds: ['table']
  }
}

module storageQueuePrivateEndpoint './private-endpoint.bicep' = {
  name: 'storage-queue-privateEndpoint-deployment'
  scope: resourceGroup()
  params: {
    name: '${abbrs.storageStorageAccounts}-queue-${abbrs.privateEndpoints}${environmentName}-${resourceToken}'
    location: location
    vnetName: vnetName
    subnetName: privateEndpointSubnetName
    dnsZoneName: privateDnsZones.storageQueuePrivateDnsZoneName
    serviceId: serviceIds.storageAccountId
    groupIds: ['queue']
  }
}

module serviceBusPrivateEndpoint './private-endpoint.bicep' = {
  name: 'servicebus-privateEndpoint-deployment'
  scope: resourceGroup()
  params: {
    name: '${abbrs.serviceBusNamespaces}${abbrs.privateEndpoints}${environmentName}-${resourceToken}'
    location: location
    vnetName: vnetName
    subnetName: privateEndpointSubnetName
    dnsZoneName: privateDnsZones.serviceBusPrivateDnsZoneName
    serviceId: serviceIds.serviceBusNamespaceId
    groupIds: ['namespace']
  }
}

module openAiPrivateEndpoint './private-endpoint.bicep' = {
  name: 'openai-privateEndpoint-deployment'
  scope: resourceGroup()
  params: {
    name: '${abbrs.cognitiveServicesAccounts}${abbrs.privateEndpoints}${environmentName}-${resourceToken}'
    location: location
    vnetName: vnetName
    subnetName: privateEndpointSubnetName
    dnsZoneName: privateDnsZones.openAiPrivateDnsZoneName
    serviceId: serviceIds.openAiId
    groupIds: ['account']
  }
}

module appStorageBlobPrivateEndpoint './private-endpoint.bicep' = {
  name: 'app-storage-blob-privateEndpoint-deployment'
  scope: resourceGroup()
  params: {
    name: '${abbrs.storageStorageAccounts}-blob-app-${abbrs.privateEndpoints}${environmentName}-${resourceToken}'
    location: location
    vnetName: vnetName
    subnetName: privateEndpointSubnetName
    dnsZoneName: privateDnsZones.storageBlobPrivateDnsZoneName
    serviceId: serviceIds.appStorageAccountId
    groupIds: ['blob']
  }
}

module appStorageFilePrivateEndpoint './private-endpoint.bicep' = {
  name: 'app-storage-file-privateEndpoint-deployment'
  scope: resourceGroup()
  params: {
    name: '${abbrs.storageStorageAccounts}-file-app-${abbrs.privateEndpoints}${environmentName}-${resourceToken}'
    location: location
    vnetName: vnetName
    subnetName: privateEndpointSubnetName
    dnsZoneName: privateDnsZones.storageFilePrivateDnsZoneName
    serviceId: serviceIds.appStorageAccountId
    groupIds: ['file']
  }
}

module appStorageTablePrivateEndpoint './private-endpoint.bicep' = {
  name: 'app-storage-table-privateEndpoint-deployment'
  scope: resourceGroup()
  params: {
    name: '${abbrs.storageStorageAccounts}-table-app-${abbrs.privateEndpoints}${environmentName}-${resourceToken}'
    location: location
    vnetName: vnetName
    subnetName: privateEndpointSubnetName
    dnsZoneName: privateDnsZones.storageTablePrivateDnsZoneName
    serviceId: serviceIds.appStorageAccountId
    groupIds: ['table']
  }
}

module appStorageQueuePrivateEndpoint './private-endpoint.bicep' = {
  name: 'app-storage-queue-privateEndpoint-deployment'
  scope: resourceGroup()
  params: {
    name: '${abbrs.storageStorageAccounts}-queue-app-${abbrs.privateEndpoints}${environmentName}-${resourceToken}'
    location: location
    vnetName: vnetName
    subnetName: privateEndpointSubnetName
    dnsZoneName: privateDnsZones.storageQueuePrivateDnsZoneName
    serviceId: serviceIds.appStorageAccountId
    groupIds: ['queue']
  }
}
