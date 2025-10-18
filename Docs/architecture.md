# Architecture Deep Dive

## Network Architecture

### Hub-Spoke Topology

**Central US (Primary)**
- Hub VNet: `10.0.0.0/16`
  - Gateway Subnet: `10.0.0.0/24`
  - Firewall Subnet: `10.0.1.0/24`
  - Bastion Subnet: `10.0.2.0/24`
- Spoke VNet: `10.10.0.0/16`
  - Web: `10.10.0.0/27`
  - App: `10.10.0.64/27`
  - Data: `10.10.0.128/27`
  - Private Endpoints: `10.10.0.192/27`

**North Europe (Secondary)**
- Hub VNet: `10.10.0.0/16`
- Spoke VNet: `10.11.0.0/16`
- Same subnet structure as Central US

**Inter-Region Connectivity**
- VNet Peering (Hub-to-Hub)
- Traffic Manager for global routing
- SQL Geo-Replication

## Application Layers

### 1. Frontend Layer
- **Service:** Azure Static Web Apps
- **Features:** 4 languages, dark/light mode, responsive
- **Deployment:** GitHub Actions CI/CD
- **CDN:** Global edge caching

### 2. Backend Layer
- **Service:** Azure Functions (Consumption Plan)
- **Runtime:** Node.js 20
- **Endpoints:**
  - `GET /api/info` - System info
  - `GET /api/visitors` - Visitor count
  - `POST /api/increment` - Increment counter
  - `POST /api/failover` - Test failover
- **Integration:** VNet integrated for private access

### 3. Data Layer
- **Primary:** SQL Server (Central US)
- **Secondary:** Geo-Replica (North Europe)
- **RPO:** <5 seconds
- **RTO:** <30 seconds
- **Backups:** 
  - Automated every 12 hours
  - 35-day retention
  - 5-year long-term retention

### 4. Storage Layer
- **Service:** Azure Storage Accounts (GRS)
- **Protection:**
  - Blob versioning
  - Soft delete (30 days)
  - Change feed enabled

## Security Architecture

### Zero Trust Model

**Network Isolation**
- All PaaS services in private subnets
- No public internet exposure
- NSGs on all subnets (allow-list only)

**Private Connectivity**
- Private Endpoints for:
  - SQL Database
  - Storage Account
  - Key Vault
- Private DNS Zones for name resolution

**Identity & Access**
- User-Assigned Managed Identity
- RBAC with least privilege
- No passwords in code

**Secrets Management**
- All secrets in Azure Key Vault
- Key Vault references in app settings
- Managed Identity authentication

## Disaster Recovery

### Traffic Manager Configuration
- **Routing:** Priority-based
- **Primary:** Central US (Priority 1)
- **Secondary:** North Europe (Priority 2)
- **Health Probes:** Every 30 seconds
- **Failover Time:** <30 seconds

### SQL Geo-Replication
- **Type:** Active Geo-Replication
- **Lag:** <5 seconds
- **Mode:** Read-only secondary
- **Failover:** Manual or automatic

### Recovery Scenarios

**Scenario 1: Region Failure**
1. Traffic Manager detects health probe failure
2. Routes traffic to secondary region
3. Function App connects to geo-replica
4. Total failover: <30 seconds

**Scenario 2: Database Failure**
1. Geo-replica promoted to primary
2. Connection strings updated
3. Application continues without interruption

## Monitoring Architecture

### Centralized Logging
- **Service:** Log Analytics Workspace
- **Retention:** 30 days
- **Sources:** All Azure resources

### Application Performance
- **Service:** Application Insights
- **Tracking:**
  - Request/response times
  - Dependencies (SQL, Storage)
  - Exceptions and failures
  - Custom metrics

### Alerting
- **Metric Alerts:**
  - Function response time >5s
  - HTTP 5xx errors
  - SQL DTU >80%
- **Notifications:** Email via Action Groups

## Resource Organization

### Resource Groups (per region)

```
rg-cloudres-network-{region}-prod     # VNets, NSGs, Peering
rg-cloudres-compute-{region}-prod     # Functions, Web Apps
rg-cloudres-data-{region}-prod        # SQL Server, Database
rg-cloudres-security-{region}-prod    # Key Vault, Identities
rg-cloudres-monitoring-{region}-prod  # Log Analytics, Insights
```

## Scaling Strategy

**Horizontal Scaling**
- Add regions as needed
- Traffic Manager distributes load
- Independent scaling per region

**Vertical Scaling**
- Function Apps: Auto-scale on demand
- SQL Database: Upgrade tier as needed
- Storage: Automatic scaling

## High Availability

**Component SLAs**
- Static Web Apps: 99.95%
- Azure Functions: 99.95%
- SQL Database: 99.99%
- Storage (GRS): 99.99%

**Composite SLA**
- Target: 99.95%
- Multi-region design exceeds target
- No single point of failure

---

*Architecture designed for production workloads with enterprise-grade reliability.*