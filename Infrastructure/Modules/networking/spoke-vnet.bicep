// Spoke Virtual Network - Updated for Multi-Region
param location string = 'centralus'
param vnetName string = 'vnet-spoke-centralus-prod'
param addressPrefix string = '10.10.0.0/16'

param tags object = {
  Project: 'CloudResilient'
  Environment: 'Production'
  ManagedBy: 'Bicep'
}

// Calculate subnet addresses dynamically based on the main prefix
// For 10.10.0.0/16 -> subnets will be 10.10.x.x
// For 10.11.0.0/16 -> subnets will be 10.11.x.x
var octets = split(addressPrefix, '.')
var basePrefix = '${octets[0]}.${octets[1]}'
var webSubnet = '${basePrefix}.0.0/27'
var appSubnet = '${basePrefix}.0.64/27'
var dataSubnet = '${basePrefix}.0.128/27'
var privateEndpointSubnet = '${basePrefix}.0.192/27'

resource spokeVnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: 'WebSubnet'
        properties: {
          addressPrefix: webSubnet
        }
      }
      {
        name: 'AppSubnet'
        properties: {
          addressPrefix: appSubnet
        }
      }
      {
        name: 'DataSubnet'
        properties: {
          addressPrefix: dataSubnet
        }
      }
      {
        name: 'PrivateEndpointSubnet'
        properties: {
          addressPrefix: privateEndpointSubnet
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

output vnetId string = spokeVnet.id
output vnetName string = spokeVnet.name
output privateEndpointSubnetId string = spokeVnet.properties.subnets[3].id
output webSubnetAddress string = webSubnet
output appSubnetAddress string = appSubnet
