param name string
param location string = resourceGroup().location
param tags object = {}
param sharedResourceGroupName string
param openaiKeyVaultSecretName string
param customSubDomainName string = name
param kind string = 'OpenAI'
param publicNetworkAccess string = 'Disabled'
param networkDefaultAction string = 'Deny'
param sku string = 'S0'
param keyVaultName string
param logAnalyticsWorkspaceId string = ''
param enableLogs bool = true
param enableAuditLogs bool = false
param enableMetrics bool = true
param arrayVersion0301Locations array = ['westeurope','southcentralus']
param chatGptModelVersion string = ((contains(arrayVersion0301Locations, location)) ? '0301' : '0613')
param adaModelVersion string = '2'
param deployments array = [
  {
    name: 'chat'
    model: {
      format: 'OpenAI'
      name: 'gpt-35-turbo'
      version: chatGptModelVersion
    }
    scaleSettings: {
      scaleType: 'Standard'
    }
  }
  {
    name: 'embedding'
    model: {
      format: 'OpenAI'
      name: 'text-embedding-ada-002'
      version: adaModelVersion
    }
    scaleSettings: {
      scaleType: 'Standard'
    }
  }
]

resource account 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: name
  location: location
  tags: union(tags, { 'azd-service-name': name })
  kind: kind
  properties: {
    customSubDomainName: customSubDomainName
    publicNetworkAccess: publicNetworkAccess
    networkAcls: {
      defaultAction: networkDefaultAction
    }
  }
  sku: {
    name: sku
  }
}

@batchSize(1)
resource deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = [for deployment in deployments: {
  parent: account
  name: deployment.name
  properties: {
    model: deployment.model
    raiPolicyName: contains(deployment, 'raiPolicyName') ? deployment.raiPolicyName : null
  }
  sku: contains(deployment, 'sku') ? deployment.sku : {
    name: 'Standard'
    capacity: 20
  }
}]

module keyVaultSecret '../keyvault/secret.bicep' = {
  name: '${account.name}-secret-deployment'
  scope: resourceGroup(sharedResourceGroupName)
  params: {
    keyVaultName: keyVaultName
    secretName: openaiKeyVaultSecretName
    secretValue: account.listKeys().key1
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticsettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: 'Logging'
  scope: account
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

output openAiId string = account.id
output openAiName string = account.name
output openAiEndpointUri string = '${account.properties.endpoint}openai/'
