param name string
param location string = resourceGroup().location
param tags object = {}
param sku string = 'WorkflowStandard'
param skuCode string = 'WS1'
param zoneRedundant bool = false
param hostingEnvironmentId string = ''

resource servicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: name
  location: location
  tags: union(tags, { 'azd-service-name': name })
  kind: 'app'
  sku: {
    tier: sku
    name: skuCode
  }
  properties: {
    zoneRedundant: zoneRedundant
    hostingEnvironmentProfile: !empty(hostingEnvironmentId) ? { id: hostingEnvironmentId } : null
  }
}

output id string = servicePlan.id
