// App Service Plan for Function App
param location string = 'centralus'
param appServicePlanName string = 'asp-cloudres-centralus-prod'

param tags object = {
  Project: 'CloudResilient'
  Environment: 'Production'
  ManagedBy: 'Bicep'
}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  kind: 'linux'
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  properties: {
    reserved: true  // true = Linux
  }
}

// resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
//   name: appServicePlanName
//   location: location
//   tags: tags
//   kind: 'linux'
//   sku: {
//     name: 'F1'
//     tier: 'Free'
//   }
//   properties: {
//     reserved: true  // true = Linux
//   }
// }
output appServicePlanId string = appServicePlan.id
output appServicePlanName string = appServicePlan.name
