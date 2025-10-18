param centralusFunctionAppId string
param northeuropeFunctionAppId string

param tags object = {
  Project: 'CloudResilient'
  Environment: 'Production'
  ManagedBy: 'Bicep'
}

// Traffic Manager Profile
resource trafficManager 'Microsoft.Network/trafficManagerProfiles@2022-04-01' = {
  name: 'tm-cloudres-prod'
  location: 'global'
  tags: tags
  properties: {
    profileStatus: 'Enabled'
    trafficRoutingMethod: 'Priority'
    dnsConfig: {
      relativeName: 'cloudres-app'
      ttl: 60
    }
    monitorConfig: {
      protocol: 'HTTPS'
      port: 443
      path: '/api/info'
      intervalInSeconds: 30
      timeoutInSeconds: 10
      toleratedNumberOfFailures: 3
    }
  }
}

// Central US Endpoint (Priority 1 - Primary)
resource centralusEndpoint 'Microsoft.Network/trafficManagerProfiles/azureEndpoints@2022-04-01' = {
  parent: trafficManager
  name: 'centralus-endpoint'
  properties: {
    targetResourceId: centralusFunctionAppId
    endpointStatus: 'Enabled'
    priority: 1
    weight: 1
  }
}

// North Europe Endpoint (Priority 2 - Secondary)
resource northeuropeEndpoint 'Microsoft.Network/trafficManagerProfiles/azureEndpoints@2022-04-01' = {
  parent: trafficManager
  name: 'northeurope-endpoint'
  properties: {
    targetResourceId: northeuropeFunctionAppId
    endpointStatus: 'Enabled'
    priority: 2
    weight: 1
  }
}

output trafficManagerUrl string = 'https://${trafficManager.properties.dnsConfig.fqdn}'
output trafficManagerFqdn string = trafficManager.properties.dnsConfig.fqdn
output trafficManagerId string = trafficManager.id
output centralusEndpointId string = centralusEndpoint.id
output northeuropeEndpointId string = northeuropeEndpoint.id
