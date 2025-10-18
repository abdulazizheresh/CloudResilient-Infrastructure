[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$SkipResourceGroups,

    [Parameter(Mandatory=$false)]
    [SecureString]$SqlAdminPassword,

    [Parameter(Mandatory=$false)]
    [SecureString]$githubToken
)

$ErrorActionPreference = "Stop"
$WarningPreference = "SilentlyContinue"

# =====================================================
# CONFIGURATION
# =====================================================

$Config = @{
    Region          = "centralus"
    ParameterFile   = 'C:\Users\USERNAME\Documents\CloudResilient Infrastructure\Infrastructure\Parameters\centralus_parameters.json'
    ModulesBasePath = 'C:\Users\USERNAME\Documents\CloudResilient Infrastructure\Infrastructure\Modules'
    ResourceGroups  = @(
        "rg-cloudres-network-centralus-prod",
        "rg-cloudres-compute-centralus-prod",
        "rg-cloudres-data-centralus-prod",
        "rg-cloudres-security-centralus-prod",
        "rg-cloudres-monitoring-centralus-prod"
    )
}

# =====================================================
# UI HELPERS
# =====================================================
function Write-Step     { param([string]$Message,[int]$Step,[int]$Total); Write-Host "`n[$Step/$Total] $Message" -ForegroundColor Cyan; Write-Host ("="*60) -ForegroundColor DarkGray }
function Write-Success  { param([string]$Message); Write-Host "  ✓ $Message" -ForegroundColor Green }
function Write-Progress { param([string]$Message); Write-Host "  → $Message" -ForegroundColor Gray }
function Write-Error    { param([string]$Message); Write-Host "  ✗ $Message" -ForegroundColor Red }

# =====================================================
# PRE-FLIGHT CHECKS
# =====================================================
Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  CloudResilient - Central US Deployment            ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan

function ConvertTo-Hashtable([object]$obj) { 
    if ($null -eq $obj) { return @{} }
    if ($obj -is [hashtable]) { return $obj }
    $ht = @{}
    $obj.PSObject.Properties | ForEach-Object { $ht[$_.Name] = $_.Value }
    return $ht
}

# Azure context
$context = Get-AzContext
if (-not $context) { Write-Error "Not logged in. Run 'Connect-AzAccount'"; exit 1 }
Write-Success "Azure context: $($context.Subscription.Name)"

# Parameters file
Write-Host "Looking for parameters at: $($Config.ParameterFile)" -ForegroundColor DarkCyan
$paramPath = Resolve-Path -LiteralPath $Config.ParameterFile -ErrorAction SilentlyContinue
if (-not $paramPath) {
    Write-Error "Parameter file not found: $($Config.ParameterFile)"
    $dir = Split-Path -Parent $Config.ParameterFile
    if (Test-Path -LiteralPath $dir) {
        Get-ChildItem -LiteralPath $dir | Select-Object Name, Length, LastWriteTime
    }
    exit 1
}

$ParamContent = Get-Content -LiteralPath $paramPath -Raw -Encoding UTF8 | ConvertFrom-Json
$Params = $ParamContent.parameters
$Tags   = ConvertTo-Hashtable $Params.tags.value
Write-Success "Parameters loaded"

# Validate module files exist
$NeededModules = @(
 'networking\hub-vnet.bicep',
 'networking\spoke-vnet.bicep',
 'networking\nsg.bicep',
 'networking\vnet-peering.bicep',
 'storage\storage-account.bicep',
 'security\managed-identity.bicep',
 'security\key-vault.bicep',
 'database\sql-server.bicep',
 'monitoring\log-analytics.bicep',
 'monitoring\app-insights.bicep',
 'compute\app-service-plan.bicep',
 'compute\function-app.bicep',
 'compute\static-web-app.bicep',
 'backup\recovery-vault.bicep'
)
foreach ($rel in $NeededModules) {
    $f = Join-Path $Config.ModulesBasePath $rel
    if (-not (Test-Path -LiteralPath $f)) { Write-Error "Missing module file: $f"; exit 1 }
}

# Public IP
$MyPublicIp = (Invoke-RestMethod -Uri "https://api.ipify.org").Trim()
Write-Success "Public IP: $MyPublicIp"

# Object ID
$CurrentUser = Get-AzADUser -SignedIn
$ObjectId = $CurrentUser.Id
Write-Success "User Object ID: $ObjectId"

# SQL password
if (-not $SqlAdminPassword) {
    $SqlAdminPassword = Read-Host "Enter SQL Admin Password" -AsSecureString
    $SqlAdminPasswordConfirm = Read-Host "Confirm Password" -AsSecureString
    $pass1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($SqlAdminPassword))
    $pass2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($SqlAdminPasswordConfirm))
    if ($pass1 -ne $pass2) { Write-Error "Passwords do not match"; exit 1 }
}

# Github Token
if (-not $githubToken) {
    $githubToken = Read-Host "Enter Your Github Token" -AsSecureString
    $gto1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($githubToken))
}

$TotalSteps = 17

# =====================================================
# STEP 1: RESOURCE GROUPS
# =====================================================
Write-Step "Deploying Network Infrastructure" -Step 1 -Total $TotalSteps
if (-not $SkipResourceGroups) {
    Write-Step "Creating Resource Groups" -Step 1 -Total $TotalSteps
    foreach ($rg in $Config.ResourceGroups) {
        Write-Progress "Creating $rg..."
        New-AzResourceGroup -Name $rg -Location $Config.Region -Force | Out-Null
        Write-Success "$rg"
    }
}

# =====================================================
# STEP 2: NETWORKING
# =====================================================
Write-Step "Deploying Network Infrastructure" -Step 2 -Total $TotalSteps

# Hub VNet
Write-Progress "Hub VNet..."
New-AzResourceGroupDeployment `
    -ResourceGroupName "rg-cloudres-network-centralus-prod" `
    -TemplateFile (Join-Path $Config.ModulesBasePath 'networking\hub-vnet.bicep') `
    -location $Params.location.value `
    -vnetName $Params.hubVnetName.value `
    -addressPrefix $Params.hubAddressPrefix.value `
    -tags $Tags `
    -Name "hub-vnet-$(Get-Date -Format 'yyyyMMddHHmmss')" | Out-Null
Write-Success "Hub VNet"

# Spoke VNet
Write-Progress "Spoke VNet..."
New-AzResourceGroupDeployment `
    -ResourceGroupName "rg-cloudres-network-centralus-prod" `
    -TemplateFile (Join-Path $Config.ModulesBasePath 'networking\spoke-vnet.bicep') `
    -location $Params.location.value `
    -vnetName $Params.spokeVnetName.value `
    -addressPrefix $Params.spokeAddressPrefix.value `
    -tags $Tags `
    -Name "spoke-vnet-$(Get-Date -Format 'yyyyMMddHHmmss')" | Out-Null
Write-Success "Spoke VNet"

# NSGs
Write-Progress "NSGs..."
New-AzResourceGroupDeployment `
    -ResourceGroupName "rg-cloudres-network-centralus-prod" `
    -TemplateFile (Join-Path $Config.ModulesBasePath 'networking\nsg.bicep') `
    -location $Params.location.value `
    -spokeAddressPrefix $Params.spokeAddressPrefix.value `
    -tags $Tags `
    -Name "nsg-$(Get-Date -Format 'yyyyMMddHHmmss')" | Out-Null
Write-Success "NSGs"

# Peering
Write-Progress "VNet Peering..."
New-AzResourceGroupDeployment `
    -ResourceGroupName "rg-cloudres-network-centralus-prod" `
    -TemplateFile (Join-Path $Config.ModulesBasePath 'networking\vnet-peering.bicep') `
    -hubVnetName $Params.hubVnetName.value `
    -spokeVnetName $Params.spokeVnetName.value `
    -location $Params.location.value `
    -Name "peering-$(Get-Date -Format 'yyyyMMddHHmmss')" | Out-Null
Write-Success "VNet Peering"

# =====================================================
# STEP 3: STORAGE
# =====================================================
Write-Step "Deploying Storage Account" -Step 3 -Total $TotalSteps
az policy assignment list --query "[?contains(displayName, 'storage') || contains(displayName, 'public')].{Name:displayName, Effect:parameters.effect.value, Scope:scope}" -o table
New-AzResourceGroupDeployment `
    -ResourceGroupName "rg-cloudres-data-centralus-prod" `
    -TemplateFile (Join-Path $Config.ModulesBasePath 'storage\storage-account.bicep') `
    -location $Params.location.value `
    -storageAccountName $Params.storageAccountName.value `
    -tags $Tags `
    -Name "storage-$(Get-Date -Format 'yyyyMMddHHmmss')" | Out-Null
Write-Success "Storage Account"

# =====================================================
# STEP 4: DATABASE
# =====================================================
Write-Step "Deploying SQL Server & Database" -Step 4 -Total $TotalSteps
New-AzResourceGroupDeployment `
    -ResourceGroupName "rg-cloudres-data-centralus-prod" `
    -TemplateFile (Join-Path $Config.ModulesBasePath 'database\sql-server.bicep') `
    -location $Params.location.value `
    -sqlServerName $Params.sqlServerName.value `
    -sqlDatabaseName $Params.sqlDatabaseName.value `
    -administratorLogin $Params.sqlAdminUsername.value `
    -administratorLoginPassword $SqlAdminPassword `
    -myPublicIp $MyPublicIp `
    -tags $Tags `
    -Name "sql-$(Get-Date -Format 'yyyyMMddHHmmss')" | Out-Null
Write-Success "SQL Server & Database"

# =====================================================
# STEP 5: COMPUTE
# =====================================================
Write-Step "Deploying Compute" -Step 5 -Total $TotalSteps
$StorageAccountRg = "rg-cloudres-data-centralus-prod"

# App Service Plan
Write-Progress "App Service Plan..."
$aspResult = New-AzResourceGroupDeployment `
    -ResourceGroupName "rg-cloudres-compute-centralus-prod" `
    -TemplateFile (Join-Path $Config.ModulesBasePath 'compute\app-service-plan.bicep') `
    -location $Params.location.value `
    -appServicePlanName $Params.appServicePlanName.value `
    -Name "asp-$(Get-Date -Format 'yyyyMMddHHmmss')"
Write-Success "App Service Plan"

$AppSPID = (Get-AzAppServicePlan -Name "asp-cloudres-centralus-prod" -ResourceGroupName "rg-cloudres-compute-centralus-prod").Id

# Function App
Write-Progress "Function App..."
$sqlPasswordText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($SqlAdminPassword))
New-AzResourceGroupDeployment `
  -ResourceGroupName "rg-cloudres-compute-centralus-prod" `
  -TemplateFile (Join-Path $Config.ModulesBasePath 'compute\function-app.bicep') `
  -location $Params.location.value `
  -functionAppName $Params.functionAppName.value `
  -appServicePlanId $AppSPID `
  -storageAccountName $Params.storageAccountName.value `
  -storageAccountRg $StorageAccountRg `
  -sqlServerName $Params.sqlServerName.value `
  -sqlDatabaseName $Params.sqlDatabaseName.value `
  -sqlAdminLogin $Params.sqlAdminUsername.value `
  -sqlAdminPassword (ConvertTo-SecureString $sqlPasswordText -AsPlainText -Force) `
  -tags $Tags `
  -Name "function-$(Get-Date -Format 'yyyyMMddHHmmss')" | Out-Null `
  -Verbose

Write-Success "Function App"

# =====================================================
# STEP 6: Azure Static Web App
# =====================================================
Write-Step "Deploying Static Web App" -Step 6 -Total $TotalSteps
Write-Progress "Static Web App..."

New-AzResourceGroupDeployment `
  -ResourceGroupName "rg-cloudres-compute-centralus-prod" `
  -TemplateFile (Join-Path $Config.ModulesBasePath 'compute\static-web-app.bicep') `
  -repositoryUrl "[GITHUB-REPO-LINK]" `
  -location $Params.location.value `
  -staticWebAppName $Params.staticWebAppName.value `
  -branch "main" `
  -repositoryToken $githubToken

Write-Success "Static Web App"

# =====================================================
# STEP 7: KEY VAULT
# =====================================================
Write-Step "Deploying Key Vault" -Step 7 -Total $TotalSteps

New-AzResourceGroupDeployment `
    -ResourceGroupName "rg-cloudres-security-centralus-prod" `
    -TemplateFile (Join-Path $Config.ModulesBasePath 'security\key-vault.bicep') `
    -location $Params.location.value `
    -keyVaultName $Params.keyVaultName.value `
    -objectId $ObjectId `
    -Name "keyvault-$(Get-Date -Format 'yyyyMMddHHmmss')" | Out-Null


Write-Host "`nVerifying Key Vault..." -ForegroundColor Green

$keyVault = Get-AzKeyVault -ResourceGroupName rg-cloudres-security-centralus-prod -VaultName $Params.keyVaultName.value

if ($keyVault) {
    Write-Host "✅ Key Vault created successfully!" -ForegroundColor Green
    Write-Host "Name: $($keyVault.VaultName)" -ForegroundColor White
    Write-Host "URI: $($keyVault.VaultUri)" -ForegroundColor White
    Write-Host "Location: $($keyVault.Location)" -ForegroundColor White
} else {
    Write-Host "❌ Key Vault creation failed!" -ForegroundColor Red
}

Write-Success "Key Vault"

# =====================================================
# STEP 8: MANAGED IDENTITY
# =====================================================
Write-Step "Deploying Managed Identity" -Step 8 -Total $TotalSteps

New-AzResourceGroupDeployment `
    -ResourceGroupName "rg-cloudres-security-centralus-prod" `
    -TemplateFile (Join-Path $Config.ModulesBasePath 'security\managed-identity.bicep') `
    -location $Params.location.value `
    -identityName $Params.managedIdentityName.value `
    -Name "identity-$(Get-Date -Format 'yyyyMMddHHmmss')" `
    -Verbose | Out-Null

Write-Progress "Waiting for identity propagation..."
Start-Sleep -Seconds 10

$identity = Get-AzUserAssignedIdentity -ResourceGroupName "rg-cloudres-security-centralus-prod" -Name $Params.managedIdentityName.value
$subscriptionId = (Get-AzContext).Subscription.Id

# Key Vault access
Set-AzKeyVaultAccessPolicy `
  -VaultName $Params.keyVaultName.value `
  -ObjectId $identity.PrincipalId `
  -PermissionsToSecrets get,list

# Reader role + Function App assignment
az role assignment create --assignee $identity.PrincipalId --role "Reader" --scope "/subscriptions/$subscriptionId" --output none
az functionapp identity assign --name $Params.functionAppName.value --resource-group "rg-cloudres-compute-centralus-prod" --identities $identity.Id --output none
az functionapp config appsettings set -n $Params.functionAppName.value -g "rg-cloudres-compute-centralus-prod" --settings keyVaultReferenceIdentity="$($identity.Id)"

# Restart and test
Restart-AzFunctionApp -Name $Params.functionAppName.value -ResourceGroupName "rg-cloudres-compute-centralus-prod" -Force
Start-Sleep -Seconds 15
try { 
    Invoke-RestMethod -Uri "https://$($Params.functionAppName.value).azurewebsites.net/api/info" -ErrorAction Stop | Out-Null
    Write-Success "Managed Identity configured and tested"
} catch { 
    Write-Success "Managed Identity configured (Function App not responding yet)"
}

# =====================================================
# STEP 9: KEY VAULT REFERENCE IDENTITY
# =====================================================
Write-Step "Configuring Key Vault Reference" -Step 9 -Total $TotalSteps

$identityId = az identity show -g "rg-cloudres-security-centralus-prod" -n $Params.managedIdentityName.value --query id -o tsv
az functionapp update --name $Params.functionAppName.value --resource-group "rg-cloudres-compute-centralus-prod" --set keyVaultReferenceIdentity="$identityId" --output none

Write-Progress "Restarting and testing..."
Restart-AzFunctionApp -Name $Params.functionAppName.value -ResourceGroupName "rg-cloudres-compute-centralus-prod" -Force
Start-Sleep -Seconds 60

try {
    $response = Invoke-RestMethod -Uri "https://$($Params.functionAppName.value).azurewebsites.net/api/info" -ErrorAction Stop
    Write-Success "Function App is operational - Region: $($response.region)"
} catch {
    Write-Success "Key Vault Reference configured (Function App not yet deployed)"
}

# =====================================================
# STEP 10: KEY VAULT SECRETS
# =====================================================
Write-Step "Adding Secrets to Key Vault" -Step 10 -Total $TotalSteps

$subscriptionId = (Get-AzContext).Subscription.Id

# 1. SQL Admin Password
Write-Progress "Adding SQL Admin Password..."
Set-AzKeyVaultSecret -VaultName $Params.keyVaultName.value -Name "SQL-ADMIN-PASSWORD" -SecretValue $SqlAdminPassword
Write-Host "✅ SQL Admin Password added" -ForegroundColor Green

# 2. SQL Connection String
Write-Progress "Creating SQL Connection String..."
$sqlAdminPasswordText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sqlAdminPassword))
$sqlConnectionString = "Server=tcp:$($Params.sqlServerName.value).database.windows.net,1433;Database=$($Params.sqlDatabaseName.value);User ID=sqladmin;Password=$sqlAdminPasswordText;Encrypt=true;Connection Timeout=30;"
$secretSql = ConvertTo-SecureString $sqlConnectionString -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName $Params.keyVaultName.value -Name "SQL-CONNECTION-STRING" -SecretValue $secretSql
Write-Host "✅ SQL Connection String added" -ForegroundColor Green

# 3. GitHub Token
Write-Progress "Adding GitHub Token..."
Set-AzKeyVaultSecret -VaultName $Params.keyVaultName.value -Name "GITHUB-TOKEN" -SecretValue $githubToken
Write-Host "✅ GitHub Token added" -ForegroundColor Green

# 4. Storage Account Key
Write-Progress "Getting Storage Account Key..."
$storageKey = az storage account keys list --account-name $Params.storageAccountName.value --resource-group "rg-cloudres-data-centralus-prod" --query "[0].value" -o tsv
if ($storageKey) {
    $secretStorage = ConvertTo-SecureString $storageKey -AsPlainText -Force
    Set-AzKeyVaultSecret -VaultName $Params.keyVaultName.value -Name "STORAGE-ACCOUNT-KEY" -SecretValue $secretStorage
    Write-Host "✅ Storage Account Key added" -ForegroundColor Green
} else {
    Write-Host "⚠️ Storage Account not found - skipping" -ForegroundColor Yellow
}

# 5. Azure Subscription ID
Write-Progress "Adding Subscription ID..."
$secretSubId = ConvertTo-SecureString $subscriptionId -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName $Params.keyVaultName.value -Name "AZURE-SUBSCRIPTION-ID" -SecretValue $secretSubId
Write-Host "✅ Subscription ID added" -ForegroundColor Green

# 6. Region Info
Write-Progress "Adding Region..."
$secretRegion = ConvertTo-SecureString $Params.location.value -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName $Params.keyVaultName.value -Name "REGION" -SecretValue $secretRegion
Write-Host "✅ Region added" -ForegroundColor Green

# Display all secrets
Write-Host "`nAll Secrets in Key Vault:" -ForegroundColor Cyan
Get-AzKeyVaultSecret -VaultName $Params.keyVaultName.value | Select-Object Name, Created, Updated | Format-Table

Write-Success "All secrets added successfully"

# =====================================================
# STEP 11 Private DNS Zones Deployment
# =====================================================

Write-Step "Private DNS Zones Deployment" -Step 11 -Total $TotalSteps

# Get VNet ID
$vnet = Get-AzVirtualNetwork -ResourceGroupName rg-cloudres-network-centralus-prod -Name "vnet-spoke-centralus-prod"
$vnetId = $vnet.Id

Write-Host "VNet ID: $vnetId" -ForegroundColor Yellow

# Deploy DNS Zones
New-AzResourceGroupDeployment `
  -ResourceGroupName rg-cloudres-network-centralus-prod `
  -TemplateFile (Join-Path $Config.ModulesBasePath 'networking\private-dns-zones.bicep') `
  -vnetId $vnetId `
  -Verbose

Write-Success "Private DNS Zones"

# =====================================================
# STEP 12: Function App VNet Integration
# =====================================================
Write-Step "VNet Integration in Function App" -Step 12 -Total $TotalSteps

$spokeVnetId = "/subscriptions/$subscriptionId/resourceGroups/rg-cloudres-network-centralus-prod/providers/Microsoft.Network/virtualNetworks/$($Params.spokeVnetName.value)"
az functionapp vnet-integration add -g "rg-cloudres-compute-centralus-prod" -n $Params.functionAppName.value --vnet $spokeVnetId --subnet AppSubnet --output none

$identity = Get-AzUserAssignedIdentity -ResourceGroupName "rg-cloudres-security-centralus-prod" -Name $Params.managedIdentityName.value
$keyVaultUri = (Get-AzKeyVault -VaultName $Params.keyVaultName.value).VaultUri
$clientId = $identity.ClientId

$settings = @{
    "SQL_CONNECTION_STRING" = "@Microsoft.KeyVault(SecretUri=$($keyVaultUri)secrets/SQL-CONNECTION-STRING/);IdentityClientId=$clientId"
    "SQL_ADMIN_PASSWORD" = "@Microsoft.KeyVault(SecretUri=$($keyVaultUri)secrets/SQL-ADMIN-PASSWORD/);IdentityClientId=$clientId"
    "STORAGE_ACCOUNT_KEY" = "@Microsoft.KeyVault(SecretUri=$($keyVaultUri)secrets/STORAGE-ACCOUNT-KEY/);IdentityClientId=$clientId"
    "AZURE_SUBSCRIPTION_ID" = "@Microsoft.KeyVault(SecretUri=$($keyVaultUri)secrets/AZURE-SUBSCRIPTION-ID/);IdentityClientId=$clientId"
    "REGION" = "@Microsoft.KeyVault(SecretUri=$($keyVaultUri)secrets/REGION/);IdentityClientId=$clientId"
    "KEY_VAULT_URI" = $keyVaultUri
    "AZURE_CLIENT_ID" = $clientId
    "FUNCTIONS_WORKER_RUNTIME" = "node"
    "FUNCTIONS_EXTENSION_VERSION" = "~4"
    "WEBSITE_NODE_DEFAULT_VERSION" = "~20"
    "WEBSITE_VNET_ROUTE_ALL" = "1"
}
Update-AzFunctionAppSetting -Name $Params.functionAppName.value -ResourceGroupName "rg-cloudres-compute-centralus-prod" -AppSetting $settings -Force | Out-Null

Write-Success "VNet integration and app settings configured"

# =====================================================
# STEP 13: Deploy Private Endpoints
# =====================================================
Write-Step "Deploying Private Endpoints" -Step 13 -Total $TotalSteps

$vnet = Get-AzVirtualNetwork -ResourceGroupName "rg-cloudres-network-centralus-prod" -Name $Params.spokeVnetName.value
$privateEndpointSubnetId = ($vnet.Subnets | Where-Object {$_.Name -eq "PrivateEndpointSubnet"}).Id

$blobDnsZoneId = "/subscriptions/$subscriptionId/resourceGroups/rg-cloudres-network-centralus-prod/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
$sqlDnsZoneId = "/subscriptions/$subscriptionId/resourceGroups/rg-cloudres-network-centralus-prod/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net"
$kvDnsZoneId = "/subscriptions/$subscriptionId/resourceGroups/rg-cloudres-network-centralus-prod/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"

$storageAccountId = (Get-AzStorageAccount -ResourceGroupName "rg-cloudres-data-centralus-prod" -Name $Params.storageAccountName.value).Id
$sqlServerId = (Get-AzSqlServer -ResourceGroupName "rg-cloudres-data-centralus-prod" -ServerName $Params.sqlServerName.value).ResourceId
$keyVaultId = (Get-AzKeyVault -ResourceGroupName "rg-cloudres-security-centralus-prod" -VaultName $Params.keyVaultName.value).ResourceId

# Storage Blob
Write-Progress "Storage Blob Private Endpoint..."
New-AzResourceGroupDeployment -ResourceGroupName "rg-cloudres-data-centralus-prod" -TemplateFile (Join-Path $Config.ModulesBasePath 'security\private-endpoint.bicep') -privateEndpointName "pe-storage-blob" -targetResourceId $storageAccountId -groupId "blob" -subnetId $privateEndpointSubnetId -privateDnsZoneId $blobDnsZoneId -Name "pe-storage-$(Get-Date -Format 'yyyyMMddHHmmss')" | Out-Null

# SQL Server
Write-Progress "SQL Server Private Endpoint..."
New-AzResourceGroupDeployment -ResourceGroupName "rg-cloudres-data-centralus-prod" -TemplateFile (Join-Path $Config.ModulesBasePath 'security\private-endpoint.bicep') -privateEndpointName "pe-sql-server" -targetResourceId $sqlServerId -groupId "sqlServer" -subnetId $privateEndpointSubnetId -privateDnsZoneId $sqlDnsZoneId -Name "pe-sql-$(Get-Date -Format 'yyyyMMddHHmmss')" | Out-Null

# Key Vault
Write-Progress "Key Vault Private Endpoint..."
New-AzResourceGroupDeployment -ResourceGroupName "rg-cloudres-security-centralus-prod" -TemplateFile (Join-Path $Config.ModulesBasePath 'security\private-endpoint.bicep') -privateEndpointName "pe-key-vault" -targetResourceId $keyVaultId -groupId "vault" -subnetId $privateEndpointSubnetId -privateDnsZoneId $kvDnsZoneId -Name "pe-kv-$(Get-Date -Format 'yyyyMMddHHmmss')" | Out-Null

az functionapp restart -n $Params.functionAppName.value -g "rg-cloudres-compute-centralus-prod" --output none
Write-Success "Private endpoints deployed"

# =================================================================
# STEP 14: Disable Public Access After Private Endpoints Deployment
# =================================================================
Write-Step "Disable Public Access" -Step 14 -Total $TotalSteps

# 1. Disable Storage Account Public Access
Write-Host "`n[1/3] Updating Storage Account..." -ForegroundColor Yellow
az storage account update `
  --name $Params.storageAccountName.value `
  --resource-group rg-cloudres-data-centralus-prod `
  --public-network-access Disabled

Write-Host "✅ Storage Account public access disabled" -ForegroundColor Green

# 2. Disable SQL Server Public Access
Write-Host "`n[2/3] Updating SQL Server..." -ForegroundColor Yellow
az sql server update `
  --name $Params.sqlServerName.value `
  --resource-group rg-cloudres-data-centralus-prod `
  --set publicNetworkAccess="Disabled"

Write-Host "✅ SQL Server public access disabled" -ForegroundColor Green

# 3. Update Key Vault Network Rules
Write-Host "`n[3/3] Updating Key Vault..." -ForegroundColor Yellow
az keyvault update `
  --name $Params.keyVaultName.value `
  --resource-group rg-cloudres-security-centralus-prod `
  --default-action Deny `
  --bypass AzureServices

Write-Host "`n✅ All public access disabled successfully!" -ForegroundColor Green

# ==========================================================
# STEP 15: Monitoring Deployment
# ==========================================================
Write-Step "Monitoring Deployment" -Step 15 -Total $TotalSteps

$monitoringRg = "rg-cloudres-monitoring-centralus-prod"
$computeRg = "rg-cloudres-compute-centralus-prod"
$networkRg = "rg-cloudres-network-centralus-prod"

# 1. Deploy Log Analytics
Write-Host "`n[1/2] Deploying Log Analytics..." -ForegroundColor Yellow
$logDeployment = New-AzResourceGroupDeployment `
  -ResourceGroupName $monitoringRg `
  -TemplateFile (Join-Path $Config.ModulesBasePath 'monitoring\log-analytics.bicep') `
  -location $Params.location.value `
  -workspaceName $Params.logAnalyticsName.value `
  -Verbose
$workspaceId = $logDeployment.Outputs.workspaceId.Value
Write-Host "✅ Done" -ForegroundColor Green

# 3. Deploy Alerts
Write-Host "`n[2/2] Deploying Alerts..." -ForegroundColor Yellow
$email = Read-Host "Enter email for alerts"
New-AzResourceGroupDeployment `
  -ResourceGroupName "rg-cloudres-monitoring-centralus-prod" `
  -TemplateFile (Join-Path $Config.ModulesBasePath 'monitoring\alerts.bicep') `
  -actionGroupName $Params.actionGroupName.value `
  -emailAddress $email `
  -functionAppName $Params.functionAppName.value `
  -functionAppRg "rg-cloudres-compute-centralus-prod" `
  -sqlServerName $Params.sqlServerName.value `
  -sqlServerRg "rg-cloudres-data-centralus-prod" `
  -sqlDatabaseName $Params.sqlDatabaseName.value `
  -Name "alerts-$(Get-Date -Format 'yyyyMMddHHmmss')" | Out-Null


Write-Success "Monitoring Deployment Completed!"

# =====================================================
# STEP 16: DIAGNOSTIC SETTINGS
# =====================================================
Write-Step "Configuring Diagnostic Settings" -Step 16 -Total $TotalSteps

$workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName "rg-cloudres-monitoring-centralus-prod" -Name $Params.logAnalyticsName.value
$workspaceId = $workspace.ResourceId
$subscriptionId = (Get-AzContext).Subscription.Id

# Function App
Write-Host "`n[1/4] Function App" -ForegroundColor Yellow
az monitor diagnostic-settings create --resource "/subscriptions/$subscriptionId/resourceGroups/rg-cloudres-compute-centralus-prod/providers/Microsoft.Web/sites/$($Params.functionAppName.value)" --name "diag-func" --workspace $workspaceId --logs '[{"category":"FunctionAppLogs","enabled":true}]' --metrics '[{"category":"AllMetrics","enabled":true}]' --output none 2>$null

# SQL Database (not server)
Write-Host "`n[2/4] SQL Database" -ForegroundColor Yellow
az monitor diagnostic-settings create --resource "/subscriptions/$subscriptionId/resourceGroups/rg-cloudres-data-centralus-prod/providers/Microsoft.Sql/servers/$($Params.sqlServerName.value)/databases/$($Params.sqlDatabaseName.value)" --name "diag-sql" --workspace $workspaceId --logs '[{"category":"SQLInsights","enabled":true},{"category":"QueryStoreRuntimeStatistics","enabled":true}]' --metrics '[{"category":"AllMetrics","enabled":true}]' --output none 2>$null

# Storage Blob
Write-Host "`n[3/4] Storage Blob" -ForegroundColor Yellow
az monitor diagnostic-settings create --resource "/subscriptions/$subscriptionId/resourceGroups/rg-cloudres-data-centralus-prod/providers/Microsoft.Storage/storageAccounts/$($Params.storageAccountName.value)/blobServices/default" --name "diag-storage" --workspace $workspaceId --logs '[{"category":"StorageRead","enabled":true},{"category":"StorageWrite","enabled":true}]' --metrics '[{"category":"Transaction","enabled":true}]' --output none 2>$null

# Key Vault
Write-Host "`n[4/4] Key Vault" -ForegroundColor Yellow
az monitor diagnostic-settings create --resource "/subscriptions/$subscriptionId/resourceGroups/rg-cloudres-security-centralus-prod/providers/Microsoft.KeyVault/vaults/$($Params.keyVaultName.value)" --name "diag-kv" --workspace $workspaceId --logs '[{"category":"AuditEvent","enabled":true}]' --metrics '[{"category":"AllMetrics","enabled":true}]' --output none 2>$null

Write-Success "Diagnostic settings configured"

# =====================================================
# STEP 17: BACKUP CONFIGURATION
# =====================================================
Write-Step "Configuring Backup & Recovery" -Step 17 -Total $TotalSteps

# Recovery Vault
Write-Progress "Deploying Recovery Services Vault..."
New-AzResourceGroupDeployment -ResourceGroupName "rg-cloudres-data-centralus-prod" -TemplateFile (Join-Path $Config.ModulesBasePath 'backup\recovery-vault.bicep') -vaultName $Params.recoveryVaultName.value -location $Params.location.value -Name "backup-$(Get-Date -Format 'yyyyMMddHHmmss')" -Verbose | Out-Null

# SQL Backup Policies
Write-Progress "Configuring SQL backup policies..."
az sql db str-policy set -g "rg-cloudres-data-centralus-prod" --server $Params.sqlServerName.value --name $Params.sqlDatabaseName.value --retention-days 35 --diffbackup-hours 24 --output none
az sql db ltr-policy set -g "rg-cloudres-data-centralus-prod" --server $Params.sqlServerName.value --name $Params.sqlDatabaseName.value --weekly-retention "P4W" --monthly-retention "P12M" --yearly-retention "P5Y" --week-of-year 1 --output none

# Storage Protection
Write-Progress "Enabling storage account protection..."
az storage account blob-service-properties update --account-name $Params.storageAccountName.value -g "rg-cloudres-data-centralus-prod" --enable-delete-retention true --delete-retention-days 30 --enable-container-delete-retention true --container-delete-retention-days 30 --enable-versioning true --enable-change-feed true --output none

Write-Success "Backup and recovery configured"

# =====================================================
# SUMMARY
# =====================================================
Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  Deployment Completed Successfully! ✓                ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "  1. Deploy Function code" -ForegroundColor Cyan
Write-Host "  2. Setup SQL Geo-Replication" -ForegroundColor Cyan
Write-Host "  3. Configure Traffic Manager" -ForegroundColor Cyan
Write-Host ""
