# Create All Resource Groups for CloudResilient Project

$location1 = "centralus"
$location2 = "northeurope"
$tags = "Project=CloudResilient Environment=Production ManagedBy=Bicep"

# Central US Resource Groups
$rgsCentralUS = @(
    "rg-cloudres-network-centralus-prod",
    "rg-cloudres-compute-centralus-prod",
    "rg-cloudres-data-centralus-prod",
    "rg-cloudres-security-centralus-prod",
    "rg-cloudres-monitoring-centralus-prod"
)

# North Europe Resource Groups
$rgsNorthEurope = @(
    "rg-cloudres-network-northeurope-prod",
    "rg-cloudres-compute-northeurope-prod",
    "rg-cloudres-data-northeurope-prod",
    "rg-cloudres-security-northeurope-prod",
    "rg-cloudres-monitoring-northeurope-prod"
)

Write-Host "Creating Resource Groups in Central US..." -ForegroundColor Cyan
foreach ($rg in $rgsCentralUS) {
    Write-Host "  Creating: $rg" -ForegroundColor Yellow
    az group create --name $rg --location $location1 --tags $tags
}

Write-Host "`nCreating Resource Groups in North Europe..." -ForegroundColor Cyan
foreach ($rg in $rgsNorthEurope) {
    Write-Host "  Creating: $rg" -ForegroundColor Yellow
    az group create --name $rg --location $location2 --tags $tags
}

Write-Host "`n✅ All Resource Groups created successfully!" -ForegroundColor Green

# List all created RGs
Write-Host "`nVerifying..." -ForegroundColor Cyan
az group list --query "[?contains(name, 'cloudres')].{Name:name, Location:location}" -o table