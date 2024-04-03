param namespace string
param name string
param maxSizeMB int = 1024
param duplicateDetection bool = false
param duplicateDetectionHistoryTimeWindow string = 'PT10M'
param defaultMessageTimeToLive string = 'PT7D'
param partitioning bool = false

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  name: namespace
}

resource topic 'Microsoft.ServiceBus/namespaces/topics@2021-06-01-preview' = {
  parent: serviceBusNamespace
  name: name
  properties: {
    maxSizeInMegabytes: maxSizeMB
    defaultMessageTimeToLive: defaultMessageTimeToLive
    requiresDuplicateDetection: duplicateDetection
    duplicateDetectionHistoryTimeWindow: duplicateDetectionHistoryTimeWindow
    enablePartitioning: partitioning
  }
}
