// NSG Flow Logs
param location string = 'centralus'
param nsgName string = 'nsg-spoke-centralus-prod'
param storageAccountId string
param workspaceId string

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' existing = {
  name: nsgName
}

resource flowLog 'Microsoft.Network/networkWatchers/flowLogs@2023-05-01' = {
  name: 'NetworkWatcher_${location}/flowlog-${nsgName}'
  location: location
  properties: {
    targetResourceId: nsg.id
    storageId: storageAccountId
    enabled: true
    retentionPolicy: {
      days: 7
      enabled: true
    }
    format: {
      type: 'JSON'
      version: 2
    }
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: true
        workspaceResourceId: workspaceId
        trafficAnalyticsInterval: 10
      }
    }
  }
}

output flowLogId string = flowLog.id
