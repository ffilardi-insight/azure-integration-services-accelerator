param apimServiceName string
param keyVaultEndpoint string
param openAiKeyVaultSecretName string
param openAiUri string

var openAiApiBackendId = 'openai-backend'

resource  apimService 'Microsoft.ApiManagement/service@2021-08-01' existing = {
  name: apimServiceName
}

resource apimOpenAiApi 'Microsoft.ApiManagement/service/apis@2022-08-01' = {
  name: 'azure-openai-service-api'
  parent: apimService
  properties: {
    path: 'openai'
    apiRevision: '1'
    displayName: 'Azure OpenAI Service API'
    subscriptionRequired: true
    format: 'openapi+json'
    value: string(loadJsonContent('./api/openai-api-specification.json'))
    protocols: [
      'https'
    ]
  }
}

resource openAiBackend 'Microsoft.ApiManagement/service/backends@2021-08-01' = {
  name: openAiApiBackendId
  parent: apimService
  properties: {
    description: openAiApiBackendId
    url: openAiUri
    protocol: 'http'
    tls: {
      validateCertificateChain: true
      validateCertificateName: true
    }
  }
}

resource apimOpenaiApiKeyNamedValue 'Microsoft.ApiManagement/service/namedValues@2022-08-01' = {
  name: openAiKeyVaultSecretName
  parent: apimService
  properties: {
    displayName: openAiKeyVaultSecretName
    secret: true
    keyVault:{
      secretIdentifier: '${keyVaultEndpoint}secrets/${openAiKeyVaultSecretName}'
    }
  }
}

resource openaiApiPolicy 'Microsoft.ApiManagement/service/apis/policies@2022-08-01' = {
  name: 'policy'
  parent: apimOpenAiApi
  properties: {
    value: loadTextContent('./policy/openai-api-policy.xml')
    format: 'rawxml'
  }
  dependsOn: [
    openAiBackend
    apimOpenaiApiKeyNamedValue
  ]
}

resource apiOperationCompletions 'Microsoft.ApiManagement/service/apis/operations@2020-06-01-preview' existing = {
  name: 'ChatCompletions_Create'
  parent: apimOpenAiApi
}

resource chatCompletionsCreatePolicy 'Microsoft.ApiManagement/service/apis/operations/policies@2022-08-01' = {
  name: 'policy'
  parent: apiOperationCompletions
  properties: {
    value: loadTextContent('./policy/openai-api-operation-policy.xml')
    format: 'rawxml'
  }
}

output apiPath string = apimOpenAiApi.properties.path
