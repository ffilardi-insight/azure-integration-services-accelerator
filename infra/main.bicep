targetScope = 'subscription'

@minLength(3)
@maxLength(10)
param environmentName string

@allowed(['westeurope', 'southcentralus', 'australiaeast', 'canadaeast', 'eastus', 'eastus2', 'francecentral', 'japaneast', 'northcentralus', 'swedencentral', 'switzerlandnorth', 'uksouth'])
param location string

// Enable the deployment of specific services
param deployAse bool = false

// Resource Groups
param networkResourceGroupName string = ''
param monitorResourceGroupName string = ''
param sharedResourceGroupName string = ''
param integrationResourceGroupName string = ''

// Network & Connectivity Services
param vnetName string = ''
param privateEndpointSubnetName string = ''
param privateEndpointNsgName string = ''
param apimSubnetName string = ''
param apimNsgName string = ''
param appSubnetName string = ''
param appNsgName string = ''

// Logs & Monitoring Services
param logAnalyticsName string = ''
param applicationInsightsName string = ''
param applicationInsightsDashboardName string = ''

// Shared Services
param keyVaultName string = ''
param storageAccountName string = ''
param openAiServiceName string = ''

// Integration Services
param serviceBusName string = ''
param apimServiceName string = ''
param aseServiceName string = ''
param workflowAppName string = ''
param servicePlanName string = ''

// Set global variables
var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'azd-env-name': environmentName }

// Set service variables
var openaiKeyVaultSecretName = 'openai-apikey'
var privateLinkScopeName = 'private-link-scope'

// Set DNS Zone variables
var keyVaultPrivateDnsZoneName = 'privatelink.vaultcore.azure.net'
var privateLinkPrivateDnsZoneName = 'privatelink.monitor.azure.com'
var storageBlobPrivateDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'
var storageFilePrivateDnsZoneName = 'privatelink.file.${environment().suffixes.storage}'
var storageQueuePrivateDnsZoneName = 'privatelink.queue.${environment().suffixes.storage}'
var storageTablerivateDnsZoneName = 'privatelink.table.${environment().suffixes.storage}'
var serviceBusPrivateDnsZoneName = 'privatelink.servicebus.windows.net'
var openAiPrivateDnsZoneName = 'privatelink.openai.azure.com'
var asePrivateDnsZoneName = 'privatelink.appserviceenvironment.net'

// Resource Groups

resource networkResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(networkResourceGroupName) ? networkResourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}-network-${resourceToken}'
  location: location
  tags: tags
}

resource monitorResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(monitorResourceGroupName) ? monitorResourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}-monitor-${resourceToken}'
  location: location
  tags: tags
}

resource sharedResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(sharedResourceGroupName) ? sharedResourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}-shared-${resourceToken}'
  location: location
  tags: tags
}

resource integrationResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(integrationResourceGroupName) ? integrationResourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}-integration-${resourceToken}'
  location: location
  tags: tags
}

// Networking & Connectivity Services

module network './modules/network/network.bicep' = {
  name: 'network'
  scope: networkResourceGroup
  params: {
    vnetName: !empty(vnetName) ? vnetName : '${abbrs.networkVirtualNetworks}${environmentName}-${resourceToken}'
    location: location
    tags: tags
    logAnalyticsWorkspaceId: monitor.outputs.logAnalyticsWorkspaceId
    privateEndpointSubnetName: !empty(privateEndpointSubnetName) ? privateEndpointSubnetName : '${abbrs.networkVirtualNetworksSubnets}${abbrs.privateEndpoints}${environmentName}-${resourceToken}'
    privateEndpointNsgName: !empty(privateEndpointNsgName) ? privateEndpointNsgName : '${abbrs.networkNetworkSecurityGroups}${abbrs.privateEndpoints}${environmentName}-${resourceToken}'
    apimSubnetName: !empty(apimSubnetName) ? apimSubnetName : '${abbrs.networkVirtualNetworksSubnets}${abbrs.apiManagementService}${environmentName}-${resourceToken}'
    apimNsgName: !empty(apimNsgName) ? apimNsgName : '${abbrs.networkNetworkSecurityGroups}${abbrs.apiManagementService}${environmentName}-${resourceToken}'
    appSubnetName: !empty(appSubnetName) ? appSubnetName : '${abbrs.networkVirtualNetworksSubnets}${abbrs.webSitesAppService}${environmentName}-${resourceToken}'
    appNsgName: !empty(appNsgName) ? appNsgName : '${abbrs.networkNetworkSecurityGroups}${abbrs.webSitesAppService}${environmentName}-${resourceToken}'
    deployAse: deployAse
    privateDnsZoneNames: [
      keyVaultPrivateDnsZoneName
      privateLinkPrivateDnsZoneName
      storageBlobPrivateDnsZoneName
      storageFilePrivateDnsZoneName
      storageQueuePrivateDnsZoneName
      storageTablerivateDnsZoneName
      serviceBusPrivateDnsZoneName
      openAiPrivateDnsZoneName
      asePrivateDnsZoneName
    ]
  }
}

// Logs & Monitoring Services

module monitor './modules/monitor/monitor.bicep' = {
  name: 'monitor'
  scope: monitorResourceGroup
  params: {
    location: location
    tags: tags
    logAnalyticsName: !empty(logAnalyticsName) ? logAnalyticsName : '${abbrs.operationalInsightsWorkspaces}${environmentName}-${resourceToken}'
    applicationInsightsName: !empty(applicationInsightsName) ? applicationInsightsName : '${abbrs.insightsComponents}${environmentName}-${resourceToken}'
    applicationInsightsDashboardName: !empty(applicationInsightsDashboardName) ? applicationInsightsDashboardName : '${abbrs.portalDashboards}${environmentName}-${resourceToken}'
    privateLinkScopeName: privateLinkScopeName
  }
}

// Shared Services

module keyVault './modules/keyvault/keyvault.bicep' = {
  name: 'keyvault'
  scope: sharedResourceGroup
  params: {
    name: !empty(keyVaultName) ? keyVaultName : '${abbrs.keyVaultVaults}${environmentName}-${resourceToken}'
    location: location
    tags: tags
    logAnalyticsWorkspaceId: monitor.outputs.logAnalyticsWorkspaceId
  }
}

module storageAccount './modules/storage/storage.bicep' = {
  name: 'storage'
  scope: sharedResourceGroup
  params: {
    name: !empty(storageAccountName) ? '${replace(storageAccountName,'-','')}' : '${abbrs.storageStorageAccounts}${replace(environmentName,'-','')}${resourceToken}'
    location: location
    tags: tags
    logAnalyticsWorkspaceId: monitor.outputs.logAnalyticsWorkspaceId
    isHnsEnabled: true
  }
}

// Apps & Integration Services

module apim './modules/apim/apim.bicep' = {
  name: 'apim'
  scope: integrationResourceGroup
  params: {
    name: !empty(apimServiceName) ? apimServiceName : '${abbrs.apiManagementService}${environmentName}-${resourceToken}'
    location: location
    tags: tags
    applicationInsightsId: monitor.outputs.applicationInsightsId
    applicationInsightsInstrumentationKey: monitor.outputs.applicationInsightsInstrumentationKey
    sharedResourceGroupName: sharedResourceGroup.name
    networkResourceGroupName: networkResourceGroup.name
    keyVaultName: keyVault.outputs.keyVaultName
    keyVaultEndpoint: keyVault.outputs.keyVaultEndpoint
    apimSubnetId: network.outputs.apimSubnetId
    logAnalyticsWorkspaceId: monitor.outputs.logAnalyticsWorkspaceId
    api: {
      openai: {
        keyVaultSecretName: openaiKeyVaultSecretName
        uri: openAi.outputs.openAiEndpointUri
      }
    }
  }
}

module serviceBusNamespace './modules/servicebus/servicebus.bicep' = {
  name: 'servicebus'
  scope: integrationResourceGroup
  params: {
    name: !empty(serviceBusName) ? serviceBusName : '${abbrs.serviceBusNamespaces}${environmentName}-${resourceToken}'
    location: location
    tags: tags
    logAnalyticsWorkspaceId: monitor.outputs.logAnalyticsWorkspaceId
  }
}

module openAi 'modules/ai/cognitiveservices.bicep' = {
  name: 'openai'
  scope: integrationResourceGroup
  params: {
    name: !empty(openAiServiceName) ? openAiServiceName : '${abbrs.cognitiveServicesAccounts}${environmentName}-${resourceToken}'
    location: location
    tags: tags
    sharedResourceGroupName: sharedResourceGroup.name
    keyVaultName: keyVault.outputs.keyVaultName
    openaiKeyVaultSecretName: openaiKeyVaultSecretName
    logAnalyticsWorkspaceId: monitor.outputs.logAnalyticsWorkspaceId
  }
}

module ase './modules/ase/ase.bicep' = if (deployAse) {
  name: 'ase'
  scope: integrationResourceGroup
  params: {
    name: !empty(aseServiceName) ? aseServiceName : '${abbrs.webSitesAppServiceEnvironment}${environmentName}-${resourceToken}'
    location: location
    tags: tags
    networkResourceGroupName: networkResourceGroup.name
    subnetId: network.outputs.appSubnetId
    privateDnsZoneName: asePrivateDnsZoneName
    logAnalyticsWorkspaceId: monitor.outputs.logAnalyticsWorkspaceId
  }
}

module frontDoor './modules/frontdoor/cdn.bicep' = {
  name: 'frontdoor'
  scope: integrationResourceGroup
  params: {
    name: '${abbrs.networkFrontDoors}${environmentName}-${resourceToken}'
    tags: tags
    apimServiceName: apim.outputs.apimName
    proxyEndpointName: '${abbrs.networkFrontDoors}proxy-${resourceToken}'
    proxyOriginHostName: apim.outputs.apimProxyHostName
    developerPortalEndpointName: '${abbrs.networkFrontDoors}portal-${resourceToken}'
    developerPortalOriginHostName: apim.outputs.apimDeveloperPortalHostName
    logAnalyticsWorkspaceId: monitor.outputs.logAnalyticsWorkspaceId
  }
  dependsOn: [
    apim
  ]
}

module apps './modules/apps/apps.bicep' = {
  name: 'apps'
  scope: integrationResourceGroup
  params: {
    location: location
    tags: tags
    workflowAppName: !empty(workflowAppName) ? workflowAppName : '${abbrs.logicWorkflows}${environmentName}-${resourceToken}'
    servicePlanName: !empty(servicePlanName) ? servicePlanName : '${abbrs.webServerFarms}${environmentName}-${resourceToken}'
    subnetId: deployAse ? '' : network.outputs.appSubnetId
    hostingEnvironmentId: deployAse ? ase.outputs.aseId : ''
    appInsightsConnectionString: monitor.outputs.applicationInsightsConnectionString
    logAnalyticsWorkspaceId: monitor.outputs.logAnalyticsWorkspaceId
  }
}

// Private Endpoints

module privateEndpointConfig './modules/network/private-endpoint-config.bicep' = {
  name: 'private-endpoint-config'
  scope: networkResourceGroup
  params: {
    environmentName: environmentName
    resourceToken: resourceToken
    location: location
    vnetName: network.outputs.vnetName
    privateEndpointSubnetName: network.outputs.privateEndpointSubnetName
    privateDnsZones: {
      keyVaultPrivateDnsZoneName: keyVaultPrivateDnsZoneName
      privateLinkPrivateDnsZoneName: privateLinkPrivateDnsZoneName
      storageBlobPrivateDnsZoneName: storageBlobPrivateDnsZoneName
      storageFilePrivateDnsZoneName: storageFilePrivateDnsZoneName
      storageQueuePrivateDnsZoneName: storageQueuePrivateDnsZoneName
      storageTablePrivateDnsZoneName: storageTablerivateDnsZoneName
      serviceBusPrivateDnsZoneName: serviceBusPrivateDnsZoneName
      openAiPrivateDnsZoneName: openAiPrivateDnsZoneName
      asePrivateDnsZoneName: asePrivateDnsZoneName
    }
    serviceIds: {
      privateLinkScopeId: monitor.outputs.privateLinkScopeId
      keyVaultId: keyVault.outputs.keyVaultId
      monitorId: monitor.outputs.privateLinkScopeId
      storageAccountId: storageAccount.outputs.accountId
      serviceBusNamespaceId: serviceBusNamespace.outputs.serviceBusNamespaceId
      openAiId: openAi.outputs.openAiId
      aseId: deployAse ? ase.outputs.aseId : ''
      appStorageAccountId: apps.outputs.workflowAppStorageAccountId
    }
  }
}

// Output system variables

output TENTANT_ID string = subscription().tenantId
output AZURE_LOCATION string = location
output AZURE_VNET_NAME string = network.outputs.vnetName
output AZURE_LOG_ANALYTICS_NAME string = monitor.outputs.logAnalyticsWorkspaceName
output AZURE_KEY_VAULT_NAME string = keyVault.outputs.keyVaultName
output AZURE_SERVICE_BUS_NAME string = serviceBusNamespace.outputs.serviceBusNamespace
output AZURE_STORAGE_ACCOUNT_NAME string = storageAccount.outputs.accountName
output AZURE_OPEN_AI_SERVICE_NAME string = openAi.outputs.openAiName
output AZURE_APPLICATION_INSIGHTS_NAME string = monitor.outputs.applicationInsightsName
output AZURE_APPLICATION_INSIGHTS_DASHBOARD_NAME string = monitor.outputs.applicationInsightsDashboardName
output AZURE_FRONT_DOOR_NAME string = frontDoor.outputs.frontDoorName
output AZURE_FRONT_DOOR_PROXY_ENDPOINT_NAME string = frontDoor.outputs.frontDoorProxyEndpointHostName
output AZURE_FRONT_DOOR_PORTAL_ENDPOINT_NAME string = frontDoor.outputs.frontDoorDeveloperPortalEndpointHostName
output AZURE_WORKFLOW_APP_NAME string = apps.outputs.workflowAppName
output AZURE_ASE_SERVICE_NAME string = deployAse ? ase.outputs.aseName : ''
