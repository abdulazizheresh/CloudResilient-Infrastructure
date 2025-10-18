// Private Endpoint Module
@description('Location for the private endpoint')
param location string = resourceGroup().location

@description('Name of the private endpoint')
param privateEndpointName string

@description('Resource ID of the target resource (Storage, SQL, KeyVault)')
param targetResourceId string

@description('Group ID for the private endpoint (blob, file, sqlServer, vault)')
param groupId string

@description('Subnet ID where the private endpoint will be created')
param subnetId string

@description('Private DNS Zone ID for DNS integration')
param privateDnsZoneId string

param tags object = {
  Project: 'CloudResilient'
  Environment: 'Production'
  ManagedBy: 'Bicep'
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: privateEndpointName
  location: location
  tags: tags
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: targetResourceId
          groupIds: [
            groupId
          ]
        }
      }
    ]
  }
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

output privateEndpointId string = privateEndpoint.id
output privateEndpointName string = privateEndpoint.name
