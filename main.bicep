targetScope = 'resourceGroup'

param location string = 'westeurope'
param localAdminUsername string = 'logcorner'
@secure()
param localAdminPassword string = 'LongAndStrongP@ssw0rd1234'
param storageAccountName string = 'logcornerstprivdnsrev'
@allowed([
  'FirstStage'
  'EndStage'
])
@description('Select either FirstStage or EndStage, based on whether or not you want the complete setup with Private Resolver or not. See readme for more information.')
param Stage string

module hubvnet './hubvnet.bicep' = {
  name: 'hubvnet'
  params: {
    location: location
  }
}

module spokevnet './spokevnet.bicep' = {
  name: 'spokevnet'
  params: {
    location: location
    Stage: Stage
  }
}



module VMs './VMs.bicep' = {
  name: 'VMs'
  params: {
    location: location
    localAdminUsername: localAdminUsername
    localAdminPassword: localAdminPassword
    spokesubnetID: spokevnet.outputs.spokesubnetID
  }
}

 module vnetpeering './vnetPeering.bicep' = {
  name: 'vnetpeering'
  params: {
    HubID: hubvnet.outputs.vnetID
    SpokeID: spokevnet.outputs.vnetID
   
  }
}  

module bastion 'bastion.bicep' = {
  name: 'bastion'
  params: {
    HubSubnetID: hubvnet.outputs.bastionSubnetID
    location: location
  }
}

module storage 'storage.bicep' = {
  name: 'storage'
  params: {
    location: location
    hubVnetID: hubvnet.outputs.vnetID
    spokeVnetID: spokevnet.outputs.vnetID
    spokeSubnetID: spokevnet.outputs.spokesubnetID
    storageAccountName: storageAccountName
  }
}

module privateresolver 'privateresolver.bicep' = if (Stage == 'EndStage') {
  name: 'privateresolver'
  params: {
    location: location
    hubvnetID: hubvnet.outputs.vnetID
    inboundSubnetID: hubvnet.outputs.inboundSubnetID
   
  }
}


