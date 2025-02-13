param location string
param hubvnetID string
param inboundSubnetID string
resource privateResolver 'Microsoft.Network/dnsResolvers@2022-07-01' = {
  name: 'privateResolver'
  location: location
  properties: {
    virtualNetwork: {
      id: hubvnetID
    }
  }
}

resource inboundEndpoint 'Microsoft.Network/dnsResolvers/inboundEndpoints@2022-07-01' = {
  name: 'inboundEndpoint'
  location: location
  parent: privateResolver
  properties: {
    ipConfigurations: [
      {
        privateIpAddress: '10.200.0.70'
        privateIpAllocationMethod: 'Static'
        subnet: {
          id: inboundSubnetID
        }
      }
    ]
  }
}


