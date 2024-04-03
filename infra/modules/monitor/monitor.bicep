param logAnalyticsName string
param applicationInsightsName string
param applicationInsightsDashboardName string
param privateLinkScopeName string
param location string = resourceGroup().location
param tags object = {}

module logAnalytics 'loganalytics.bicep' = {
  name: 'log-analytics'
  params: {
    name: logAnalyticsName
    location: location
    tags: tags
  }
}

module applicationInsights 'applicationinsights.bicep' = {
  name: 'application-insights'
  params: {
    name: applicationInsightsName
    location: location
    tags: tags
    dashboardName: applicationInsightsDashboardName
    logAnalyticsWorkspaceId: logAnalytics.outputs.id
  }
}

module privateLinkScope '../network/private-link-scope.bicep' = {
  name: 'private-link-scope'
  params: {
    privateLinkScopeName: privateLinkScopeName
    logAnalyticsName: logAnalytics.outputs.name
    logAnalyticsId: logAnalytics.outputs.id
    applicationInsightsName: applicationInsights.outputs.appInsightsName
    applicationInsightsId: applicationInsights.outputs.appInsightsId
  }
}

output applicationInsightsConnectionString string = applicationInsights.outputs.connectionString
output applicationInsightsInstrumentationKey string = applicationInsights.outputs.instrumentationKey
output applicationInsightsId string = applicationInsights.outputs.appInsightsId
output applicationInsightsName string = applicationInsights.outputs.appInsightsName
output applicationInsightsDashboardName string = applicationInsights.outputs.dashboardName
output logAnalyticsWorkspaceId string = logAnalytics.outputs.id
output logAnalyticsWorkspaceName string = logAnalytics.outputs.name
output privateLinkScopeId string = privateLinkScope.outputs.scopeId
