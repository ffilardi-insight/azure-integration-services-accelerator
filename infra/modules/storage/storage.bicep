param name string
param location string = resourceGroup().location
param tags object = {}
param kind string = 'StorageV2'
param sku string = 'Standard_LRS'
param publicNetworkAccess string = 'Disabled'
param minimumTlsVersion string = 'TLS1_2'
param supportsHttpsTrafficOnly bool = true
param allowBlobPublicAccess bool = false
param allowSharedKeyAccess bool = true
param defaultOAuth bool = false
param allowedCopyScope string = 'PrivateLink'
param accessTier string = 'Hot'
param allowCrossTenantReplication bool = false
param networkAclsBypass string = 'AzureServices'
param networkAclsDefaultAction string = 'Deny'
param networkAclsVirtualNetworkRules array = []
param networkAclsIpRules array = []
param dnsEndpointType string = 'Standard'
param isHnsEnabled bool = false
param isSftpEnabled bool = false
param isBlobSoftDeleteEnabled bool = true
param blobSoftDeleteRetentionDays int = 7
param isContainerSoftDeleteEnabled bool = true
param containerSoftDeleteRetentionDays int = 7
param isShareSoftDeleteEnabled bool = true
param shareSoftDeleteRetentionDays int = 7
param keySource string = 'Microsoft.Storage'
param encryptionEnabled bool = true
param infrastructureEncryptionEnabled bool = false
param logAnalyticsWorkspaceId string = ''

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: name
  location: location
  tags: union(tags, { 'azd-service-name': name })
  kind: kind
  sku: {
    name: sku
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    minimumTlsVersion: minimumTlsVersion
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    defaultToOAuthAuthentication: defaultOAuth
    allowedCopyScope: allowedCopyScope
    accessTier: accessTier
    publicNetworkAccess: publicNetworkAccess
    allowCrossTenantReplication: allowCrossTenantReplication
    networkAcls: {
      bypass: networkAclsBypass
      defaultAction: networkAclsDefaultAction
      virtualNetworkRules: networkAclsVirtualNetworkRules
      ipRules: networkAclsIpRules
    }
    dnsEndpointType: dnsEndpointType
    isHnsEnabled: isHnsEnabled
    isSftpEnabled: isSftpEnabled
    encryption: {
      keySource: keySource
      services: {
        blob: {
          enabled: encryptionEnabled
        }
        file: {
          enabled: encryptionEnabled
        }
        table: {
          enabled: encryptionEnabled
        }
        queue: {
          enabled: encryptionEnabled
        }
      }
      requireInfrastructureEncryption: infrastructureEncryptionEnabled
    }
  }
}

module blobServices './blob.bicep' = {
  name: 'blob'
  params: {
    storageAccountName: storageAccount.name
    isBlobSoftDeleteEnabled: isBlobSoftDeleteEnabled
    blobSoftDeleteRetentionDays: blobSoftDeleteRetentionDays
    isContainerSoftDeleteEnabled: isContainerSoftDeleteEnabled
    containerSoftDeleteRetentionDays: containerSoftDeleteRetentionDays
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}

module fileServices './file.bicep' = {
  name: 'file'
  params: {
    storageAccountName: storageAccount.name
    isShareSoftDeleteEnabled: isShareSoftDeleteEnabled
    shareSoftDeleteRetentionDays: shareSoftDeleteRetentionDays
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}

module tableServices './table.bicep' = {
  name: 'table'
  params: {
    storageAccountName: storageAccount.name
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}

module queueServices './queue.bicep' = {
  name: 'queue'
  params: {
    storageAccountName: storageAccount.name
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}

output accountId string = storageAccount.id
output accountName string = storageAccount.name
