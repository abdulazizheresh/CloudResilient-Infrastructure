# =====================================================
# Deploy Traffic Manager
# =====================================================

Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     Traffic Manager Deployment                       ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# =====================================================
# Step 1: Get Function App IDs
# =====================================================
Write-Host "[1/3] Getting Function App IDs..." -ForegroundColor Cyan

$centralusFuncApp = Get-AzWebApp -ResourceGroupName "rg-cloudres-compute-centralus-prod" -Name "func-cloudres-centralus-prod"
$northeuropeFuncApp = Get-AzWebApp -ResourceGroupName "rg-cloudres-compute-northeurope-prod" -Name "func-cloudres-northeurope-prod"

if (-not $centralusFuncApp) {
    Write-Host "❌ Central US Function App not found!" -ForegroundColor Red
    exit 1
}

if (-not $northeuropeFuncApp) {
    Write-Host "❌ North Europe Function App not found!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Central US Function App ID: $($centralusFuncApp.Id)" -ForegroundColor Green
Write-Host "✅ North Europe Function App ID: $($northeuropeFuncApp.Id)" -ForegroundColor Green

# =====================================================
# Step 2: Create Resource Group for Traffic Manager
# =====================================================
Write-Host "`n[2/3] Creating Resource Group..." -ForegroundColor Cyan

$tmRgName = "rg-cloudres-global-prod"
$tmRg = Get-AzResourceGroup -Name $tmRgName -ErrorAction SilentlyContinue

if (-not $tmRg) {
    New-AzResourceGroup -Name $tmRgName -Location "centralus" -Force | Out-Null
    Write-Host "✅ Resource Group created: $tmRgName" -ForegroundColor Green
} else {
    Write-Host "✅ Resource Group already exists: $tmRgName" -ForegroundColor Yellow
}

# =====================================================
# Step 3: Deploy Traffic Manager
# =====================================================
Write-Host "`n[3/3] Deploying Traffic Manager..." -ForegroundColor Cyan

$templatePath = "C:\Users\USERNAME\Documents\CloudResilient Infrastructure\Infrastructure\Modules\dr\traffic-manager.bicep"

if (-not (Test-Path $templatePath)) {
    Write-Host "❌ Template file not found: $templatePath" -ForegroundColor Red
    exit 1
}

$deployment = New-AzResourceGroupDeployment `
    -ResourceGroupName $tmRgName `
    -TemplateFile $templatePath `
    -centralusFunctionAppId $centralusFuncApp.Id `
    -northeuropeFunctionAppId $northeuropeFuncApp.Id `
    -Name "traffic-manager-$(Get-Date -Format 'yyyyMMddHHmmss')" `
    -Verbose

if ($deployment.ProvisioningState -eq "Succeeded") {
    Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║   ✅ Traffic Manager Deployed Successfully!          ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Green
    
    Write-Host "`n📊 Deployment Details:" -ForegroundColor Cyan
    Write-Host "  🌐 Traffic Manager URL: $($deployment.Outputs.trafficManagerUrl.Value)" -ForegroundColor White
    Write-Host "  🔗 FQDN: $($deployment.Outputs.trafficManagerFqdn.Value)" -ForegroundColor White
    Write-Host "  🆔 Traffic Manager ID: $($deployment.Outputs.trafficManagerId.Value)" -ForegroundColor Gray
    
    # =====================================================
    # Step 4: Test Traffic Manager
    # =====================================================
    Write-Host "`n[Testing] Waiting 30 seconds for DNS propagation..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30
    
    $tmUrl = $deployment.Outputs.trafficManagerUrl.Value
    Write-Host "`n🧪 Testing Traffic Manager endpoint..." -ForegroundColor Cyan
    
    try {
        $response = Invoke-RestMethod -Uri "$tmUrl/api/info" -ErrorAction Stop
        Write-Host "✅ Traffic Manager is working!" -ForegroundColor Green
        Write-Host "   Region: $($response.region)" -ForegroundColor White
        Write-Host "   Status: $($response.status)" -ForegroundColor White
    } catch {
        Write-Host "⚠️  Traffic Manager deployed but not responding yet." -ForegroundColor Yellow
        Write-Host "   Try again in a few minutes: $tmUrl/api/info" -ForegroundColor Gray
    }
    
} else {
    Write-Host "`n❌ Deployment failed!" -ForegroundColor Red
    Write-Host "Error: $($deployment.ProvisioningState)" -ForegroundColor Red
}

Write-Host "`n✅ Done!" -ForegroundColor Green