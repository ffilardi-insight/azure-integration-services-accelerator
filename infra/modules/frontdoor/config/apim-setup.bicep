param apimServiceName string
param frontDoorId string

resource apimService 'Microsoft.ApiManagement/service@2021-08-01' existing = {
  name: apimServiceName

  resource frontDoorIdNamedValue 'namedValues' = {
    name: 'frontdoor-id'
    properties: {
      displayName: 'frontdoor-id'
      value: frontDoorId
      secret: true
    }
  }

  resource globalPolicy 'policies' = {
    name: 'policy'
    dependsOn: [
      frontDoorIdNamedValue
    ]
    properties: {
      value: loadTextContent('../../apim/policy/frontdoor-global-policy.xml')
      format: 'xml'
    }
  }
}
