param namespace string
param name string
param maxSizeMB int = 1024
param lockDuration string = 'PT5M'
param duplicateDetection bool = false
param duplicateDetectionHistoryTimeWindow string = 'PT10M'
param maxDeliveryCount int = 10
param defaultMessageTimeToLive string = 'PT7D'
param deadLetteringOnMessageExpiration bool = false
param requiresSession bool = false
param partitioning bool = false

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  name: namespace
}

resource serviceBusQueue 'Microsoft.ServiceBus/namespaces/queues@2022-01-01-preview' = {
  parent: serviceBusNamespace
  name: name
  properties: {
    lockDuration: lockDuration
    maxSizeInMegabytes: maxSizeMB
    requiresDuplicateDetection: duplicateDetection
    requiresSession: requiresSession
    defaultMessageTimeToLive: defaultMessageTimeToLive
    deadLetteringOnMessageExpiration: deadLetteringOnMessageExpiration
    duplicateDetectionHistoryTimeWindow: duplicateDetectionHistoryTimeWindow
    maxDeliveryCount: maxDeliveryCount
    enablePartitioning: partitioning
  }
}
