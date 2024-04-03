param location string = resourceGroup().location
param tags object = {}
param workflowAppName string
param servicePlanName string
param subnetId string = ''
param logAnalyticsWorkspaceId string = ''
param appInsightsConnectionString string = ''
param hostingEnvironmentId string = ''

var abbrs = loadJsonContent('../../abbreviations.json')
var storageName = '${abbrs.storageStorageAccounts}${replace(workflowAppName,'-','')}'

module storage '../../modules/storage/storage.bicep' = {
  name: 'workflow-app-storage'
  params: {
    name: storageName
    location: location
    tags: tags
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    publicNetworkAccess: 'Enabled'
    networkAclsDefaultAction: 'Allow'
  }
}

module servicePlan './service-plan.bicep' = {
  name: 'workflow-app-service-plan'
  params: {
    name: servicePlanName
    location: location
    tags: tags
    hostingEnvironmentId: hostingEnvironmentId
    sku: empty(hostingEnvironmentId) ? 'WorkflowStandard' : 'IsolatedV2'
    skuCode: empty(hostingEnvironmentId) ? 'WS1' : 'I1V2'
  }
  dependsOn: [
    storage
  ]
}

module workflowApp './workflow.bicep' = {
  name: 'workflow-app'
  params: {
    name: workflowAppName
    location: location
    tags: tags
    hostingEnvironmentId: hostingEnvironmentId
    servicePlanId: servicePlan.outputs.id
    storageAccountName: storage.outputs.accountName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    appInsightsConnectionString: appInsightsConnectionString
    vnetSubnetId: subnetId
  }
  dependsOn: [
    storage
    servicePlan
  ]
}

output workflowAppName string = workflowApp.outputs.name
output workflowAppStorageAccountId string = storage.outputs.accountId
