param location string
param localAdminUsername string
@secure()
param localAdminPassword string
param spokesubnetID string



resource SpokeVMNic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'SpokeVMNic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: spokesubnetID
          }
        }
      }
    ]
  }
}







resource SpokeVM 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: 'SpokeVM'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D4s_v5'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    osProfile: {
      computerName: 'SpokeVM'
      adminUsername: localAdminUsername
      adminPassword: localAdminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: SpokeVMNic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }     
  }
}



resource autoShutdownSpoke 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: 'shutdown-computevm-SpokeVM'
  location: location
  properties: {
    status: 'Enabled'
    dailyRecurrence: {
      time: '17:00'
    }
    timeZoneId: 'UTC'
    targetResourceId: SpokeVM.id
    taskType: 'ComputeVmShutdownTask'
  }
}
