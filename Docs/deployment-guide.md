# Deployment Guide

## Prerequisites

### Required Tools
```powershell
# Azure PowerShell
Install-Module -Name Az -AllowClobber -Scope CurrentUser

# Azure CLI
winget install Microsoft.AzureCLI

# Git
winget install Git.Git
```

### Required Access
- Azure Subscription (Owner or Contributor)
- GitHub account with repository access
- GitHub Personal Access Token (PAT)

### Before You Start
1. Choose two Azure regions (check service availability)
2. Prepare custom domain (optional, for Traffic Manager)
3. Note your GitHub repository URL
4. Generate GitHub PAT with `repo` and `workflow` permissions

## Deployment Steps

### Phase 1: Deploy Central US (Primary)

```powershell
# Navigate to scripts folder
cd Infrastructure/Scripts/

# Run deployment
./deploy-centralus.ps1
```

**What happens:**
- Creates 5 resource groups
- Deploys Hub + Spoke VNets
- Creates NSGs with security rules
- Deploys SQL Server + Database
- Creates Function App + Static Web App
- Configures Key Vault + Managed Identity
- Sets up Private Endpoints
- Enables monitoring and alerts

**Duration:** ~45 minutes

**Inputs Required:**
- SQL Admin password
- GitHub repository URL
- GitHub PAT token

### Phase 2: Deploy North Europe (Secondary)

```powershell
./deploy-northeurope.ps1
```

**What happens:**
- Mirrors Central US deployment
- Creates replica infrastructure
- Same configuration, different region

**Duration:** ~45 minutes

### Phase 3: Setup Disaster Recovery

```powershell
./setup-geo-replica-and-set-hub_to_hub-peering.ps1
```

**What happens:**
- Creates VNet peering between regions (Hub-to-Hub)
- Configures SQL Geo-Replication
- Enables read-only secondary database

**Duration:** ~10 minutes

**Critical:** Verify geo-replication status
```powershell
az sql db replica list-links \
  --name db-cloudres-centralus-prod \
  --resource-group rg-cloudres-data-centralus-prod \
  --server sql-cloudres-centralus-prod
```

### Phase 4: Deploy Traffic Manager

```powershell
./deploy-traffic-manager.ps1
```

**What happens:**
- Creates Traffic Manager profile
- Adds both regions as endpoints
- Configures priority routing
- Sets health probes

**Duration:** ~5 minutes

**Important:** If using custom domain, configure DNS:
```
CNAME record: app.yourdomain.com → cloudres-app.trafficmanager.net
```

### Phase 5: Deploy Backend Functions

```powershell
./Deploy-functions-files-To-Azure-Function.ps1
```

**What happens:**
- Packages Backend files
- Deploys to both Function Apps
- Updates application settings
- Restarts Function Apps

**Duration:** ~10 minutes

### Phase 6: Deploy Database Schema

```powershell
# Connect to SQL Database
sqlcmd -S sql-cloudres-centralus-prod.database.windows.net \
       -d db-cloudres-centralus-prod \
       -U sqladmin \
       -i ../Database/schema.sql
```

**Duration:** <1 minute

## Post-Deployment Verification

### 1. Check Resource Health
```powershell
# Get all resource health
az resource list --query "[?resourceGroup contains 'cloudres'].{Name:name, Type:type, Location:location}" -o table
```

### 2. Test Frontend
```
https://{your-static-web-app}.azurestaticapps.net
```

### 3. Test API Endpoints
```powershell
# Get system info
curl https://azuretest100.site/api/info

# Get visitor count
curl https://azuretest100.site/api/visitors

# Increment counter
curl -X POST https://azuretest100.site/api/increment
```

### 4. Test Failover
```powershell
# Trigger failover test
curl -X POST https://azuretest100.site/api/failover
```

### 5. Verify Private Endpoints
```powershell
# Check private endpoint connections
az network private-endpoint list --resource-group rg-cloudres-security-centralus-prod -o table
```

### 6. Check Monitoring
- Open Azure Portal → Application Insights
- Verify data flowing
- Check alerts are configured

## Deployment Timeline

| Phase | Duration | Status |
|-------|----------|--------|
| Phase 1: Central US | 45 min | ⏱️ |
| Phase 2: North Europe | 45 min | ⏱️ |
| Phase 3: DR Setup | 10 min | ⏱️ |
| Phase 4: Traffic Manager | 5 min | ⏱️ |
| Phase 5: Functions | 10 min | ⏱️ |
| Phase 6: Database | 1 min | ⏱️ |
| **Total** | **~116 min** | |

## Common Parameters

### Edit Parameter Files

**Central US:** `Infrastructure/Parameters/centralus.parameters.json`
```json
{
  "location": "centralus",
  "environment": "prod",
  "projectName": "cloudres"
}
```

**North Europe:** `Infrastructure/Parameters/northeurope.parameters.json`
```json
{
  "location": "northeurope",
  "environment": "prod",
  "projectName": "cloudres"
}
```

## Cleanup (Optional)

### Delete All Resources
```powershell
# Delete all resource groups
$resourceGroups = az group list --query "[?contains(name, 'cloudres')].name" -o tsv

foreach ($rg in $resourceGroups) {
    az group delete --name $rg --yes --no-wait
}
```

**Warning:** This deletes EVERYTHING. Cannot be undone.

## Troubleshooting Deployment

See [troubleshooting.md](./troubleshooting.md) for common issues.

---

*Deployment tested on Windows 11 with PowerShell 7+*