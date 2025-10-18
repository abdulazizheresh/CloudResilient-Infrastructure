// Hub Virtual Network - Updated for Multi-Region
param location string = 'centralus'
param vnetName string = 'vnet-hub-centralus-prod'
param addressPrefix string = '10.0.0.0/16'

param tags object = {
  Project: 'CloudResilient'
  Environment: 'Production'
  ManagedBy: 'Bicep'
}

// Calculate subnet addresses based on the main prefix
var baseOctet = split(addressPrefix, '.')[1]
var gatewaySubnet = '10.${baseOctet}.0.0/24'
var firewallSubnet = '10.${baseOctet}.1.0/24'
var bastionSubnet = '10.${baseOctet}.2.0/24'

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
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
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: gatewaySubnet
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: firewallSubnet
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: bastionSubnet
        }
      }
    ]
  }
}

output vnetId string = hubVnet.id
output vnetName string = hubVnet.name
