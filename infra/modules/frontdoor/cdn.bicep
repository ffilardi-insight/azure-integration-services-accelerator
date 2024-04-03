param name string
param tags object = {}
@allowed([
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
])
param skuName string = 'Premium_AzureFrontDoor'
param apimServiceName string = ''
param proxyEndpointName string
param proxyOriginHostName string
param developerPortalEndpointName string
param developerPortalOriginHostName string
param logAnalyticsWorkspaceId string = ''
param enableLogs bool = true
param enableAuditLogs bool = false
param enableMetrics bool = true

resource profile 'Microsoft.Cdn/profiles@2022-11-01-preview' = {
  name: name
  location: 'global'
  tags: union(tags, { 'azd-service-name': name })
  sku: {
    name: skuName
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticsettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: 'Logging'
  scope: profile
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        categoryGroup: 'audit'
        enabled: enableAuditLogs
      }
      {
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

module apimEndpoints './config/apim-endpoints.bicep' = {
  name: '${name}-apim-endpoints'
  scope: resourceGroup()
  params: {
    profileName: profile.name
    proxyEndpointName: proxyEndpointName
    proxyOriginHostName: proxyOriginHostName
    developerPortalEndpointName: developerPortalEndpointName
    developerPortalOriginHostName: developerPortalOriginHostName
  }
}

module apimWafPolicies './config/apim-waf-policies.bicep' = {
  name: '${name}-apim-waf-policies'
  scope: resourceGroup()
  params: {
    profileName: profile.name
    securityPolicyDomains: [
      {
        id: apimEndpoints.outputs.proxyEndpointId
      }
      {
        id: apimEndpoints.outputs.developerPortalId
      }
    ]
  }
}

module apimSetup './config/apim-setup.bicep' = {
  name: '${name}-apim-setup'
  scope: resourceGroup()
  params: {
    apimServiceName: apimServiceName
    frontDoorId: profile.properties.frontDoorId
  }
}

output frontDoorId string = profile.properties.frontDoorId
output frontDoorName string = profile.name
output frontDoorProxyEndpointHostName string = apimEndpoints.outputs.proxyEndpointHostName
output frontDoorDeveloperPortalEndpointHostName string = apimEndpoints.outputs.developerPortalEndpointHostName
