param name string
param location string = resourceGroup().location
param publicIpSku string = 'Standard'
param publicIPAllocationMethod string = 'Static'
param dnsLabelPrefix string = toLower('${name}-${uniqueString(resourceGroup().id)}')

resource publicIp 'Microsoft.Network/publicIPAddresses@2020-05-01' = {
  name: name
  location: location
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
  }
}

output id string = publicIp.id
