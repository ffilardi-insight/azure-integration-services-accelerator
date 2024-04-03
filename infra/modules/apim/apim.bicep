param name string
param location string = resourceGroup().location
param tags object = {}
@minLength(1)
param publisherEmail string = 'noreply@email.com'
@minLength(1)
param publisherName string = 'n/a'
param sku string = 'Developer'
param skuCount int = 1
param availabilityZones array = []
param vnetType string = 'External'
param publicIpName string = 'apim-public-ip'
param applicationInsightsId string
param applicationInsightsInstrumentationKey string
param keyVaultName string
param keyVaultEndpoint string
param apimSubnetId string
param logAnalyticsWorkspaceId string = ''
param sharedResourceGroupName string
param networkResourceGroupName string
param enableLogs bool = true
param enableAuditLogs bool = false
param enableMetrics bool = true
param api object = {}

// Standard role definition: Key Vault Secrets User
var keyVaultRoleDefinitionId = '4633458b-17de-408a-b874-0445c86b69e6'

module apimPublicIp '../network/public-ip.bicep' = {
  name: publicIpName
  scope: resourceGroup(networkResourceGroupName)
  params: {
    name: publicIpName
    location: location
  }
}

resource apimService 'Microsoft.ApiManagement/service@2023-05-01-preview' = {
  name: name
  location: location
  tags: union(tags, { 'azd-service-name': name })
  sku: {
    name: sku
    capacity: (sku == 'Consumption') ? 0 : ((sku == 'Developer') ? 1 : skuCount)
  }
  zones: ((length(availabilityZones) == 0) ? null : availabilityZones)
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    virtualNetworkType: vnetType
    virtualNetworkConfiguration: {
      subnetResourceId: apimSubnetId
    }
    publicIpAddressId: apimPublicIp.outputs.id
    // Custom properties are not supported for Consumption SKU
    customProperties: sku == 'Consumption' ? {} : {
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_GCM_SHA256': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA256': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA256': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30': 'false'
    }
  }
}

resource apimLogger 'Microsoft.ApiManagement/service/loggers@2021-12-01-preview' = {
  name: 'appinsights-logger'
  parent: apimService
  properties: {
    credentials: {
      instrumentationKey: applicationInsightsInstrumentationKey
    }
    description: 'Logger to Azure Application Insights'
    isBuffered: false
    loggerType: 'applicationInsights'
    resourceId: applicationInsightsId
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticsettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: 'Logging'
  scope: apimService
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
        {
          category: null
          categoryGroup: 'allLogs'
          enabled: enableLogs
      }
      {
          category: null
          categoryGroup: 'audit'
          enabled: enableAuditLogs
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

module keyVaultRoleAssignment '../keyvault/role-assignment.bicep' = {
  name: 'keyvault-role-assignment'
  scope: resourceGroup(sharedResourceGroupName)
  params: {
    principalId: apimService.identity.principalId
    roleDefinitionId: keyVaultRoleDefinitionId
    serviceId: apimService.id
    keyVaultName: keyVaultName
  }
}

module apimOpenAiApi './openai-api.bicep' = if (!empty(api.openai.uri) && !empty(api.openai.keyVaultSecretName)) {
  name: 'openai-api'
  params: {
    apimServiceName: apimService.name
    keyVaultEndpoint: keyVaultEndpoint
    openAiKeyVaultSecretName: api.openai.keyVaultSecretName
    openAiUri: api.openai.uri
  }
  dependsOn: [
    keyVaultRoleAssignment
  ]
}

output apimName string = apimService.name
output apimInternalIPAddress string = apimService.properties.publicIPAddresses[0]
output apimProxyHostName string = apimService.properties.hostnameConfigurations[0].hostName
output apimDeveloperPortalHostName string = replace(apimService.properties.developerPortalUrl, 'https://', '')
