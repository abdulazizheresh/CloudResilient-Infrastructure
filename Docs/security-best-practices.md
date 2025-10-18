# Security Best Practices

## Zero Trust Architecture

### Core Principle
**"Never trust, always verify"** - No resource is trusted by default, even if inside the network.

### Implementation

**1. Network Isolation**
```
✅ All PaaS services in private subnets
✅ No public internet access to databases
✅ Private Endpoints for all critical services
✅ NSGs with allow-list (deny-by-default)
```

**2. Identity-Based Access**
```
✅ Managed Identities (no passwords)
✅ RBAC with least privilege
✅ Key Vault for all secrets
✅ No credentials in code
```

**3. Encryption**
```
✅ TLS 1.2+ for all connections
✅ HTTPS-only enforcement
✅ Data encrypted at rest
✅ SQL Always Encrypted capability
```

---

## Network Security

### NSG Rules Implementation

**Hub VNet NSGs:**
```bicep
// Gateway Subnet - Allow VPN/ExpressRoute
- Allow: 443, 1194 from Internet
- Deny: All other

// Firewall Subnet - Allow inspection traffic
- Allow: Any from Spoke VNets
- Allow: 443 to Internet (outbound)

// Bastion Subnet - Admin access
- Allow: 443 from Internet
- Allow: 22, 3389 to VMs
```

**Spoke VNet NSGs:**
```bicep
// Web Subnet - Static Web App
- Allow: 443 from Internet (via CDN)
- Allow: 443 to App Subnet
- Deny: All other

// App Subnet - Function Apps
- Allow: 443 from Web Subnet
- Allow: 1433 to Data Subnet
- Deny: Internet access

// Data Subnet - SQL Database
- Allow: 1433 from App Subnet only
- Deny: All other

// Private Endpoint Subnet
- Allow: 443, 1433 from App Subnet
- Deny: All other
```

---

## Private Endpoints

### Services Using Private Endpoints

1. **SQL Database**
```powershell
# Private IP: 10.10.0.196 (Central US)
# DNS: sql-cloudres-centralus-prod.database.windows.net → 10.10.0.196
# Public access: Disabled
```

2. **Storage Account**
```powershell
# Private IPs: 
#   Blob: 10.10.0.197
#   File: 10.10.0.198
# Public access: Disabled for blob, file, queue, table
```

3. **Key Vault**
```powershell
# Private IP: 10.10.0.199
# Public access: Disabled
# Firewall: Deny all except Function App subnet
```

### Private DNS Zones

```
privatelink.database.windows.net     # SQL Database
privatelink.blob.core.windows.net    # Blob Storage
privatelink.file.core.windows.net    # File Storage
privatelink.vaultcore.azure.net      # Key Vault
```

**Configuration:**
- Linked to Spoke VNets
- Auto-registration disabled (manual A records)
- TTL: 300 seconds

---

## Managed Identity Configuration

### User-Assigned Identity

**Why User-Assigned?**
- Reusable across multiple resources
- Persists after resource deletion
- Better for multi-resource scenarios

**Implementation:**
```powershell
# 1. Create identity
az identity create \
  --name identity-cloudres-centralus-prod \
  --resource-group rg-cloudres-security-centralus-prod

# 2. Assign to Function App
az functionapp identity assign \
  --name func-cloudres-centralus-prod \
  --resource-group rg-cloudres-compute-centralus-prod \
  --identities /subscriptions/.../identity-cloudres-centralus-prod

# 3. Grant Key Vault permissions
az keyvault set-policy \
  --name kv-cloudres-centralus \
  --object-id <identity-principal-id> \
  --secret-permissions get list

# 4. Configure Function App
az functionapp update \
  --name func-cloudres-centralus-prod \
  --resource-group rg-cloudres-compute-centralus-prod \
  --set keyVaultReferenceIdentity="<identity-resource-id>"
```

### RBAC Roles Assigned

```
Identity: identity-cloudres-centralus-prod
├── Key Vault Secrets User (Key Vault)
├── Storage Blob Data Contributor (Storage Account)
└── SQL Database Contributor (SQL Database)
```

---

## Key Vault Best Practices

### Secret Organization

```
Secrets stored:
├── SQL-CONNECTION-STRING      # Primary SQL connection
├── SQL-CONNECTION-STRING-DR   # Secondary SQL connection
├── STORAGE-CONNECTION-STRING  # Storage account connection
└── APPINSIGHTS-KEY           # Application Insights instrumentation
```

### Access Policies

**Principle of Least Privilege:**
```powershell
# Function App identity
- Secrets: Get, List (read-only)
- Keys: None
- Certificates: None

# Admin account
- Secrets: All permissions
- Keys: All permissions
- Certificates: All permissions
```

### Key Vault Firewall

```powershell
# Default action: Deny
# Allowed:
- Private Endpoint from App Subnet (10.10.0.64/27)
- Your admin IP (temporary, for deployment)

# Best practice: Remove admin IP after deployment
az keyvault network-rule remove \
  --name kv-cloudres-centralus \
  --ip-address <your-ip>
```

---

## SQL Database Security

### Authentication

```
✅ SQL Authentication (for compatibility)
✅ Azure AD Authentication (recommended)
❌ Public access disabled
✅ Private Endpoint only
```

### Firewall Rules

```powershell
# NO public IP rules
# Only allowed via Private Endpoint from App Subnet

# Verify
az sql server firewall-rule list \
  --server sql-cloudres-centralus-prod \
  --resource-group rg-cloudres-data-centralus-prod
# Should return empty or only Azure services
```

### Advanced Data Security

```powershell
# Enable Advanced Threat Protection
az sql server threat-policy update \
  --resource-group rg-cloudres-data-centralus-prod \
  --server sql-cloudres-centralus-prod \
  --state Enabled \
  --email-admins Enabled \
  --email-addresses your-email@example.com

# Enable vulnerability assessment
az sql db threat-policy update \
  --resource-group rg-cloudres-data-centralus-prod \
  --server sql-cloudres-centralus-prod \
  --name db-cloudres-centralus-prod \
  --state Enabled
```

### Data Encryption

```
✅ TDE (Transparent Data Encryption): Enabled by default
✅ Backups encrypted
✅ Connection encrypted (TLS 1.2+)
✅ Always Encrypted: Available for sensitive columns
```

---

## Function App Security

### Application Settings Security

```powershell
# ❌ NEVER do this
--settings "SQL_PASSWORD=MyPassword123"

# ✅ ALWAYS use Key Vault references
--settings "SQL_CONNECTION_STRING=@Microsoft.KeyVault(SecretUri=https://kv-cloudres.vault.azure.net/secrets/SQL-CONNECTION-STRING)"
```

### HTTPS Enforcement

```powershell
az functionapp update \
  --name func-cloudres-centralus-prod \
  --resource-group rg-cloudres-compute-centralus-prod \
  --set httpsOnly=true

# Force TLS 1.2
az functionapp config set \
  --name func-cloudres-centralus-prod \
  --resource-group rg-cloudres-compute-centralus-prod \
  --min-tls-version 1.2
```

### VNet Integration

```
Function App → VNet Integration → Spoke VNet App Subnet
- Outbound traffic routes through VNet
- Can access Private Endpoints
- No public IP for outbound (uses NAT Gateway or VNet IP)
```

---

## Static Web App Security

### Custom Domain + SSL

```powershell
# Add custom domain
az staticwebapp hostname set \
  --name swa-cloudres-centralus \
  --resource-group rg-cloudres-compute-centralus-prod \
  --hostname app.yourdomain.com

# SSL certificate auto-provisioned by Azure
# Force HTTPS redirect enabled by default
```

### Security Headers

```javascript
// staticwebapp.config.json
{
  "globalHeaders": {
    "Strict-Transport-Security": "max-age=31536000",
    "X-Content-Type-Options": "nosniff",
    "X-Frame-Options": "DENY",
    "X-XSS-Protection": "1; mode=block"
  }
}
```

---

## Backup & Disaster Recovery Security

### SQL Backups

```
✅ Automated backups encrypted (same key as database)
✅ Geo-redundant backup storage
✅ 35-day retention
✅ Long-term retention (5 years) encrypted
```

### Storage Protection

```powershell
# Soft delete for blobs (30 days)
az storage account blob-service-properties update \
  --account-name stcloudrescentralusprod \
  --enable-delete-retention true \
  --delete-retention-days 30

# Soft delete for containers
az storage account blob-service-properties update \
  --account-name stcloudrescentralusprod \
  --enable-container-delete-retention true \
  --container-delete-retention-days 30

# Versioning
az storage account blob-service-properties update \
  --account-name stcloudrescentralusprod \
  --enable-versioning true
```

---

## Monitoring & Auditing

### Activity Logs

```powershell
# Enable diagnostic settings for all resources
az monitor diagnostic-settings create \
  --name diag-kv-cloudres \
  --resource /subscriptions/.../keyvault/kv-cloudres-centralus \
  --logs '[{"category":"AuditEvent","enabled":true}]' \
  --workspace /subscriptions/.../law-cloudres-centralus-prod
```

### Security Alerts

```
Monitor for:
- Failed authentication attempts
- Unusual access patterns
- Key Vault access from unknown IPs
- SQL injection attempts
- High-privilege operations
```

### Log Analytics Queries

```kql
// Failed Key Vault access
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.KEYVAULT"
| where ResultType != "Success"
| summarize count() by CallerIPAddress, identity_claim_upn_s

// SQL connection attempts
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.SQL"
| where Category == "SQLSecurityAuditEvents"
| where action_name_s contains "FAILED LOGIN"
```

---

## Compliance Checklist

### Azure Security Benchmark Alignment

```
✅ IM-1: Identity and Access Management
✅ NS-1: Network Security
✅ DP-1: Data Protection
✅ LT-1: Logging and Threat Detection
✅ BC-1: Backup and Recovery
✅ AM-1: Asset Management
```

### Security Scorecard

| Control | Status | Score |
|---------|--------|-------|
| No public endpoints | ✅ | 10/10 |
| Managed identities | ✅ | 10/10 |
| Secrets in Key Vault | ✅ | 10/10 |
| Network isolation | ✅ | 10/10 |
| Encryption at rest | ✅ | 10/10 |
| Encryption in transit | ✅ | 10/10 |
| RBAC configured | ✅ | 10/10 |
| Monitoring enabled | ✅ | 10/10 |
| Backup configured | ✅ | 10/10 |
| **TOTAL SCORE** | | **90/90** |

---

## Security Maintenance

### Regular Tasks

**Weekly:**
- Review access logs in Log Analytics
- Check for security alerts
- Verify backup status

**Monthly:**
- Rotate secrets in Key Vault (optional)
- Review RBAC permissions
- Update NSG rules if needed
- Check for Azure security updates

**Quarterly:**
- Review and test DR plan
- Update security documentation
- Conduct security assessment
- Review compliance status

---

## Incident Response

### If Breach Suspected

1. **Immediate:**
   - Disable affected user/identity
   - Block suspicious IPs in NSGs
   - Review access logs

2. **Investigation:**
   - Query Log Analytics for anomalies
   - Check Key Vault audit logs
   - Review SQL audit logs

3. **Remediation:**
   - Rotate all secrets
   - Update firewall rules
   - Patch vulnerabilities
   - Document findings

4. **Recovery:**
   - Restore from backups if needed
   - Re-enable services gradually
   - Monitor for 48 hours

---

## Security Tools & Commands

```powershell
# Check security recommendations
az security assessment list --query "[].{Name:name, Status:status.code}"

# Run security scan
az security secure-score-controls list

# Check for vulnerabilities
az security assessment list --query "[?status.code=='Unhealthy']"

# Review NSG flows
az network watcher flow-log list --location centralus -o table
```

---

**Security Status:** 🟢 All controls implemented and verified

*Last security review: October 2025*