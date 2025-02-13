 param location string
 @description('Select either FirstStage or EndStage, based on whether or not you want the complete setup with Private Resolver or not. See readme for more information.')
param Stage string

resource spokevnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'Spoke'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.201.0.0/24'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.201.0.0/26'
        }
      }
    ]
    dhcpOptions: Stage == 'EndStage' ? {
      dnsServers: [
        '10.200.0.70'
      ]
    } : null
  }
}

output vnetID string = spokevnet.id
output spokesubnetID string = spokevnet.properties.subnets[0].id
