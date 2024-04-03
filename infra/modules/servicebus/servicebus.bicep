param name string
param location string = resourceGroup().location
param tags object = {}
param sku string = 'Premium'
param zoneRedundat bool = false
param logAnalyticsWorkspaceId string = ''
param publicNetworkAccess string = 'Disabled'
param trustedServiceAccess bool = true
param enableLogs bool = true
param enableAuditLogs bool = false
param enableMetrics bool = true
param queues array = [
  {
    name: 'queue1'
    maxSizeMB: 1024
    lockDuration: 'PT1M'
    duplicateDetection: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 10
    defaultMessageTimeToLive: 'P7D'
    deadLetteringOnMessageExpiration: true
    requiresSession: false
    partitioning: false
  }
]
param topics array = [
  {
    name: 'topic1'
    maxSizeMB: 1024
    defaultMessageTimeToLive: 'P7D'
    duplicateDetection: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    partitioning: false
  }
]

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: name
  location: location
  tags: union(tags, { 'azd-service-name': name })
  sku: {
    name: sku
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    minimumTlsVersion: '1.2'
    zoneRedundant: zoneRedundat
  }
}

resource serviceBusNetworkRuleset 'Microsoft.ServiceBus/namespaces/networkRuleSets@2022-10-01-preview' = {
  name: 'default'
  parent: serviceBusNamespace
  properties: {
    publicNetworkAccess: publicNetworkAccess
    trustedServiceAccessEnabled: trustedServiceAccess
  }
}

module serviceBusQueues './queues.bicep' = [for queue in queues: {
  name: queue.name
  params: {
    namespace: serviceBusNamespace.name
    name: queue.name
    maxSizeMB: queue.maxSizeMB
    lockDuration: queue.lockDuration
    duplicateDetection: queue.duplicateDetection
    duplicateDetectionHistoryTimeWindow: queue.duplicateDetectionHistoryTimeWindow
    maxDeliveryCount: queue.maxDeliveryCount
    defaultMessageTimeToLive: queue.defaultMessageTimeToLive
    deadLetteringOnMessageExpiration: queue.deadLetteringOnMessageExpiration
    requiresSession: queue.requiresSession
    partitioning: queue.partitioning
  }
}]

module serviceBusTopics './topics.bicep' = [for topic in topics: {
  name: topic.name
  params: {
    namespace: serviceBusNamespace.name
    name: topic.name
    maxSizeMB: topic.maxSizeMB
    defaultMessageTimeToLive: topic.defaultMessageTimeToLive
    duplicateDetection: topic.duplicateDetection
    duplicateDetectionHistoryTimeWindow: topic.duplicateDetectionHistoryTimeWindow
    partitioning: topic.partitioning
  }
}]

resource diagnosticSettings 'Microsoft.Insights/diagnosticsettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: 'Logging'
  scope: serviceBusNamespace
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

output serviceBusNamespaceId string = serviceBusNamespace.id
output serviceBusNamespace string = serviceBusNamespace.name
