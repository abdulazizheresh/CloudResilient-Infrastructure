# Troubleshooting Guide

## Deployment Issues

### Issue 1: Service Not Available in Region

**Error:**
```
The service 'Microsoft.Web/staticSites' is not available in region 'westus'
```

**Solution:**
1. Check service availability: https://azure.microsoft.com/en-us/explore/global-infrastructure/products-by-region/
2. Choose supported region
3. Update parameter files
4. Redeploy

**Verified Regions:**
- ✅ Central US
- ✅ North Europe

---

### Issue 2: Static Web App Deployment Token Failed

**Error:**
```
Deployment token validation failed
```

**Solution:**
```powershell
# 1. Create GitHub PAT with correct permissions
# Required: repo, workflow

# 2. Update deployment script
$token = Read-Host "Enter GitHub PAT" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($token)
$githubToken = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# 3. Pass token to Bicep
--parameters repositoryUrl='https://github.com/yourusername/repo' `
            repositoryToken=$githubToken
```

---

### Issue 3: Key Vault Access Denied

**Error:**
```
Access denied to Key Vault secrets
```

**Root Cause:** Managed Identity not properly configured

**Solution:**
```powershell
# 1. Get Managed Identity ID
$identityId = az identity show `
  -g rg-cloudres-security-centralus-prod `
  -n identity-cloudres-centralus-prod `
  --query id -o tsv

# 2. Update Function App to use User-Assigned Identity
az functionapp update `
  --name func-cloudres-centralus-prod `
  --resource-group rg-cloudres-compute-centralus-prod `
  --set keyVaultReferenceIdentity="$identityId"

# 3. Restart Function App
az functionapp restart `
  --name func-cloudres-centralus-prod `
  --resource-group rg-cloudres-compute-centralus-prod

# 4. Verify
az functionapp config appsettings list `
  --name func-cloudres-centralus-prod `
  --resource-group rg-cloudres-compute-centralus-prod
```

---

### Issue 4: Traffic Manager Returns 404

**Error:**
```
404 Not Found when accessing Traffic Manager URL
```

**Root Cause:** Function Apps require custom domain configuration

**Solution:**
```powershell
# 1. Purchase domain (e.g., from Namecheap, GoDaddy)

# 2. Add custom domain to Function Apps
az functionapp config hostname add `
  --webapp-name func-cloudres-centralus-prod `
  --resource-group rg-cloudres-compute-centralus-prod `
  --hostname app.yourdomain.com

# 3. Configure DNS
CNAME: app.yourdomain.com → cloudres-app.trafficmanager.net

# 4. Wait for SSL provisioning (~10 minutes)

# 5. Test
curl https://app.yourdomain.com/api/info
```

---

### Issue 5: SQL Connection Failed in North Europe

**Error:**
```
Cannot connect to SQL Server in secondary region
```

**Root Cause:** Private DNS Zone corruption or incorrect geo-replication

**Solution:**
```powershell
# 1. Verify geo-replication exists
az sql db replica list-links `
  --name db-cloudres-centralus-prod `
  --resource-group rg-cloudres-data-centralus-prod `
  --server sql-cloudres-centralus-prod

# 2. If no replica, create it
az sql db replica create `
  --name db-cloudres-centralus-prod `
  --resource-group rg-cloudres-data-centralus-prod `
  --server sql-cloudres-centralus-prod `
  --partner-server sql-cloudres-northeurope-prod `
  --partner-resource-group rg-cloudres-data-northeurope-prod

# 3. Check Private DNS Zone
az network private-dns zone show `
  --name privatelink.database.windows.net `
  --resource-group rg-cloudres-network-northeurope-prod

# 4. If corrupted, delete and recreate
az network private-dns zone delete `
  --name privatelink.database.windows.net `
  --resource-group rg-cloudres-network-northeurope-prod --yes

# Redeploy Private DNS Zone via Bicep

# 5. Test DNS resolution from Function App
# Go to Function App → Console
nslookup sql-cloudres-northeurope-prod.database.windows.net
# Should return private IP (10.11.0.x)
```

---

## Runtime Issues

### Issue 6: Function App Cold Start Slow

**Symptom:** First request takes >5 seconds

**Solution:**
```powershell
# Option 1: Enable Always On (requires Basic tier or higher)
az functionapp config set `
  --name func-cloudres-centralus-prod `
  --resource-group rg-cloudres-compute-centralus-prod `
  --always-on true

# Option 2: Keep function warm with timer trigger
# Add to functions/KeepWarm/index.js
module.exports = async function (context) {
    context.log('Keep warm function executed');
};
```

---

### Issue 7: High SQL DTU Usage

**Symptom:** Alert triggered for DTU >80%

**Solution:**
```powershell
# Check current tier
az sql db show `
  --name db-cloudres-centralus-prod `
  --resource-group rg-cloudres-data-centralus-prod `
  --server sql-cloudres-centralus-prod `
  --query "currentServiceObjectiveName"

# Upgrade tier
az sql db update `
  --name db-cloudres-centralus-prod `
  --resource-group rg-cloudres-data-centralus-prod `
  --server sql-cloudres-centralus-prod `
  --tier Standard `
  --capacity 20
```

---

### Issue 8: CORS Error in Frontend

**Error:**
```
Access to fetch blocked by CORS policy
```

**Solution:**
```powershell
# Add CORS origins to Function App
az functionapp cors add `
  --name func-cloudres-centralus-prod `
  --resource-group rg-cloudres-compute-centralus-prod `
  --allowed-origins https://your-static-web-app.azurestaticapps.net
```

---

## Monitoring Issues

### Issue 9: No Data in Application Insights

**Symptom:** Application Insights shows no telemetry

**Solution:**
```powershell
# 1. Check connection string
az functionapp config appsettings list `
  --name func-cloudres-centralus-prod `
  --resource-group rg-cloudres-compute-centralus-prod `
  --query "[?name=='APPLICATIONINSIGHTS_CONNECTION_STRING']"

# 2. Verify instrumentation key in app
# 3. Wait 5-10 minutes for data to appear
# 4. Check Function App logs
az functionapp log tail `
  --name func-cloudres-centralus-prod `
  --resource-group rg-cloudres-compute-centralus-prod
```

---

### Issue 10: Alerts Not Triggering

**Symptom:** Metric alerts don't send emails

**Solution:**
```powershell
# 1. Verify Action Group
az monitor action-group show `
  --name ag-cloudres-centralus-prod `
  --resource-group rg-cloudres-monitoring-centralus-prod

# 2. Test Action Group
az monitor action-group test-notifications create `
  --action-group ag-cloudres-centralus-prod `
  --resource-group rg-cloudres-monitoring-centralus-prod `
  --notification-type email

# 3. Check spam folder
# 4. Verify alert rule enabled
az monitor metrics alert show `
  --name alert-function-response-time `
  --resource-group rg-cloudres-monitoring-centralus-prod
```

---

## Diagnostic Commands

### Check Resource Health
```powershell
# All resources
az resource list --resource-group rg-cloudres-compute-centralus-prod -o table

# Specific resource
az resource show --ids /subscriptions/.../resourceGroups/.../providers/...
```

### View Logs
```powershell
# Function App logs (live)
az functionapp log tail --name func-cloudres-centralus-prod -g rg-cloudres-compute-centralus-prod

# Query Log Analytics
az monitor log-analytics query `
  --workspace {workspace-id} `
  --analytics-query "FunctionAppLogs | where TimeGenerated > ago(1h)"
```

### Test Connectivity
```powershell
# From Function App console
curl https://sql-cloudres-centralus-prod.database.windows.net:1433
nslookup sql-cloudres-centralus-prod.database.windows.net
```

---

## Getting Help

1. Check Azure Portal → Service Health
2. Review Application Insights exceptions
3. Check Log Analytics for errors
4. Contact Azure Support
5. Review GitHub Issues: github.com/abdulazizheresh/CloudResilient-Infrastructure/issues

---

*Most issues resolve within 10 minutes using these solutions.*