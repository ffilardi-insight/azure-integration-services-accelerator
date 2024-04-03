param name string
param location string = resourceGroup().location
param tags object = {}
param servicePlanId string
param storageAccountName string
param hostingEnvironmentId string = ''
param appInsightsConnectionString string = ''
param logAnalyticsWorkspaceId string = ''
param enableLogs bool = true
param enableMetrics bool = true
param enabled bool = true
param use32BitWorkerProcess bool = false
param ftpsState string = 'FtpsOnly'
param netFrameworkVersion string = 'v6.0'
param alwaysOn bool = true
param functionAppScaleLimit int = 0
param clientAffinityEnabled bool = false
param clientCertEnabled bool = false
param clientCertMode string = 'Required'
param storageAccountRequired bool = false
param httpsOnly bool = true
param publicNetworkAccess string = 'Enabled'
param vnetSubnetId string = ''
param vnetPrivatePortsCount int = 2
param vnetRouteAllEnabled bool = false
param vnetContentShareEnabled bool = false
param vnetImagePullEnabled bool = false

resource workflowApp 'Microsoft.Web/sites@2022-09-01' = {
  name: name
  location: location
  tags: union(tags, { 'azd-service-name': name })
  kind: 'functionapp,workflowapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: enabled
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~18'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts',storageAccountName),'2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts',storageAccountName),'2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: '${name}-${uniqueString(resourceGroup().id)}'
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__id'
          value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__version'
          value: '[1.*, 2.0.0)'
        }
        {
          name: 'APP_KIND'
          value: 'workflowApp'
        }
      ]
      cors: {}
      use32BitWorkerProcess: use32BitWorkerProcess
      ftpsState: ftpsState
      netFrameworkVersion: netFrameworkVersion
      vnetPrivatePortsCount: vnetPrivatePortsCount
      alwaysOn: alwaysOn
      functionAppScaleLimit: functionAppScaleLimit
    }
    serverFarmId: servicePlanId
    keyVaultReferenceIdentity: 'SystemAssigned'
    publicNetworkAccess: publicNetworkAccess
    storageAccountRequired: storageAccountRequired
    httpsOnly: httpsOnly
    clientAffinityEnabled: clientAffinityEnabled
    clientCertEnabled: clientCertEnabled
    clientCertMode: clientCertMode
    hostingEnvironmentProfile: !empty(hostingEnvironmentId) ? { id: hostingEnvironmentId } : null
    virtualNetworkSubnetId: !empty(vnetSubnetId) ? vnetSubnetId : null
    vnetRouteAllEnabled: vnetRouteAllEnabled
    vnetContentShareEnabled: vnetContentShareEnabled
    vnetImagePullEnabled: vnetImagePullEnabled
  }
}

resource ftpBasicPublishingCred 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-01-01' = {
  parent: workflowApp
  name: 'ftp'
  properties: {
    allow: true
  }
}

resource scmBasicPublishingCred 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-01-01' = {
  parent: workflowApp
  name: 'scm'
  properties: {
    allow: true
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticsettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: 'Logging'
  scope: workflowApp
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
        {
          category: 'WorkflowRuntime'
          categoryGroup: null
          enabled: enableLogs
      }
      {
          category: 'FunctionAppLogs'
          categoryGroup: null
          enabled: enableLogs
      }
      {
        category: 'AppServiceAuthenticationLogs'
        categoryGroup: null
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

output name string = workflowApp.name
output defaultHost string = workflowApp.properties.defaultHostName
