@description('Location for Managed Identity')
param location string = resourceGroup().location

@description('Managed Identity name')
param identityName string = 'identity-cloudres-cus-prod'

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
  tags: {
    Environment: 'Production'
    Project: 'CloudResilient'
    ManagedBy: 'Bicep'
  }
}

output identityId string = managedIdentity.id
output identityName string = managedIdentity.name
output principalId string = managedIdentity.properties.principalId
output clientId string = managedIdentity.properties.clientId
