// Network Security Groups - Updated for Multi-Region
param location string = 'centralus'
param spokeAddressPrefix string = '10.10.0.0/16'

param tags object = {
  Project: 'CloudResilient'
  Environment: 'Production'
  ManagedBy: 'Bicep'
}

// Extract region name from location (centralus -> centralus, northeurope -> northeurope)
var regionName = location

// Calculate subnet addresses dynamically
var octets = split(spokeAddressPrefix, '.')
var basePrefix = '${octets[0]}.${octets[1]}'
var webSubnet = '${basePrefix}.0.0/27'
var appSubnet = '${basePrefix}.0.64/27'

// NSG for Web Subnet
resource nsgWeb 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'nsg-web-${regionName}-prod'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowHTTPS'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowHTTP'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// NSG for App Subnet
resource nsgApp 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'nsg-app-${regionName}-prod'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowWebToApp'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: webSubnet
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// NSG for Data Subnet
resource nsgData 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'nsg-data-${regionName}-prod'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowAppToSQL'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '1433'
          sourceAddressPrefix: appSubnet
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'DenyInternet'
        properties: {
          priority: 200
          direction: 'Outbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
        }
      }
    ]
  }
}

output nsgWebId string = nsgWeb.id
output nsgAppId string = nsgApp.id
output nsgDataId string = nsgData.id
