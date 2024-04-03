param privateDnsZoneName string
param aseInboundIpv4Address string

resource privateZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: privateDnsZoneName
}

resource webRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: privateZone
  name: '*'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: aseInboundIpv4Address
      }
    ]
  }
}

resource scmRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: privateZone
  name: '*.scm'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: aseInboundIpv4Address
      }
    ]
  }
}

resource atRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: privateZone
  name: '@'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: aseInboundIpv4Address
      }
    ]
  }
}
