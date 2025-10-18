// Recovery Services Vault for Backup
param location string = 'centralus'
param vaultName string = 'rsv-cloudres-centralus-prod'

param tags object = {
  Project: 'CloudResilient'
  Environment: 'Production'
  ManagedBy: 'Bicep'
}

resource recoveryVault 'Microsoft.RecoveryServices/vaults@2023-01-01' = {
  name: vaultName
  location: location
  tags: tags
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

// Backup Storage Configuration
resource backupStorageConfig 'Microsoft.RecoveryServices/vaults/backupstorageconfig@2023-01-01' = {
  parent: recoveryVault
  name: 'vaultstorageconfig'
  properties: {
    storageModelType: 'GeoRedundant'
    crossRegionRestoreFlag: true
  }
}

output vaultId string = recoveryVault.id
output vaultName string = recoveryVault.name
