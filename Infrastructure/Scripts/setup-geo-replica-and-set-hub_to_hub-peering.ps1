# 1. Create Geo-Replica من Central US
az sql db replica create `
  --name sqldb-cloudres-centralus-prod `
  --server sql-cloudres-centralus-prod `
  --resource-group rg-cloudres-data-centralus-prod `
  --partner-server sql-cloudres-northeurope-prod `
  --partner-resource-group rg-cloudres-data-northeurope-prod

# 2. Verify Geo-Replica Links
az sql db replica list-links `
  --name sqldb-cloudres-centralus-prod `
  --server sql-cloudres-centralus-prod `
  --resource-group rg-cloudres-data-centralus-prod


#-----------------------------------------------------------------------------------

# Set Peering Hub_to_Hub over Countries
# Central US to North Europe
az network vnet peering create `
  --name peer-to-northeurope `
  --resource-group rg-cloudres-network-centralus-prod `
  --vnet-name vnet-hub-centralus-prod `
  --remote-vnet /subscriptions/156b8fd8-efb1-4278-bc84-5a0fedfcdfc2/resourceGroups/rg-cloudres-network-northeurope-prod/providers/Microsoft.Network/virtualNetworks/vnet-hub-northeurope-prod `
  --allow-vnet-access

# North Europe to Central US  
az network vnet peering create `
  --name peer-to-centralus `
  --resource-group rg-cloudres-network-northeurope-prod `
  --vnet-name vnet-hub-northeurope-prod `
  --remote-vnet /subscriptions/156b8fd8-efb1-4278-bc84-5a0fedfcdfc2/resourceGroups/rg-cloudres-network-centralus-prod/providers/Microsoft.Network/virtualNetworks/vnet-hub-centralus-prod `
  --allow-vnet-access