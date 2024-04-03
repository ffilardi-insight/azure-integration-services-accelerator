param privateLinkScopeName string
param logAnalyticsName string
param logAnalyticsId string
param applicationInsightsName string
param applicationInsightsId string

resource privateLinkScope 'microsoft.insights/privateLinkScopes@2021-07-01-preview' = {
  name: privateLinkScopeName
  location: 'global'
  properties: {
    accessModeSettings: {
      ingestionAccessMode: 'Open'
      queryAccessMode: 'Open'
    }
  }
}

resource logAnalyticsScopedResource 'Microsoft.Insights/privateLinkScopes/scopedResources@2021-07-01-preview' = {
  parent: privateLinkScope
  name: '${logAnalyticsName}-connection'
  properties: {
    linkedResourceId: logAnalyticsId
  }
}

resource appInsightsScopedResource 'Microsoft.Insights/privateLinkScopes/scopedResources@2021-07-01-preview' = {
  parent: privateLinkScope
  name: '${applicationInsightsName}-connection'
  properties: {
    linkedResourceId: applicationInsightsId
  }
}

output scopeId string = privateLinkScope.id
output scopeName string = privateLinkScope.name
