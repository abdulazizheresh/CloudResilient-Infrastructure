# CloudResilient Infrastructure

> Multi-region Azure infrastructure with automated disaster recovery

## Overview

Production-ready Infrastructure as Code (IaC) project demonstrating enterprise-grade Azure deployment across two regions with 99.95% uptime SLA.

**Status:** ✅ Production Ready  
**Duration:** 3-4 weeks  
**Regions:** Central US (Primary) + North Europe (Secondary)

## Quick Stats

- **Resources:** 50+ Azure resources deployed
- **Code:** 20+ Bicep modules, 2000+ lines PowerShell
- **Deployment:** 17-step automated pipeline (~90 min total)
- **Cost:** $50-80/month (optimized)
- **SLA:** 99.95% uptime

## Architecture Highlights

- **Network:** Hub-Spoke topology in 2 regions
- **Compute:** Azure Functions + Static Web Apps
- **Data:** SQL Database with Geo-Replication
- **Security:** Zero Trust with Private Endpoints
- **Monitoring:** Application Insights + Log Analytics
- **DR:** Traffic Manager with <30s failover

## Key Features

✅ Multi-region deployment (Active-Active)  
✅ Automated failover and disaster recovery  
✅ Zero public endpoints (all private)  
✅ Secrets in Key Vault (zero in code)  
✅ Comprehensive monitoring and alerts  
✅ Full IaC automation with Bicep

## Tech Stack

**Infrastructure:** Bicep, PowerShell, Azure CLI  
**Frontend:** HTML5, CSS3, Vanilla JavaScript (4 languages)  
**Backend:** Node.js 20, Azure Functions v4  
**Database:** Azure SQL with T-SQL  
**Monitoring:** Application Insights, Log Analytics

## Quick Start

```powershell
# 1. Deploy Central US
./Infrastructure/Scripts/deploy-centralus.ps1

# 2. Deploy North Europe
./Infrastructure/Scripts/deploy-northeurope.ps1

# 3. Setup DR
./Infrastructure/Scripts/setup-geo-replica-and-set-hub_to_hub-peering.ps1

# 4. Deploy Traffic Manager
./Infrastructure/Scripts/deploy-traffic-manager.ps1

# 5. Deploy Functions
./Infrastructure/Scripts/Deploy-functions-files-To-Azure-Function.ps1
```

## Project Structure

```
├── Frontend/          # Static Web App (HTML/CSS/JS)
├── Backend/           # Azure Functions (Node.js)
├── Infrastructure/    # Bicep modules + deployment scripts
├── Database/          # SQL schema
├── Docs/             # Documentation
└── Tests/            # Integration & load tests
```

## Documentation

- [Architecture Deep Dive](./architecture.md)
- [Deployment Guide](./deployment-guide.md)
- [Troubleshooting](./troubleshooting.md)
- [Cost Analysis](./cost-analysis.md)
- [Security Best Practices](./security-best-practices.md)

## Live Demo

**URL:** https://azuretest100.site  
**GitHub:** github.com/abdulazizheresh/CloudResilient-Infrastructure

## Performance Metrics

| Metric | Result |
|--------|--------|
| API Response | <50ms |
| DB Query Time | <20ms |
| Failover Time | <30s |
| Uptime | 99.95%+ |

## Prerequisites

- Azure Subscription (Owner/Contributor access)
- Azure PowerShell module
- Azure CLI
- GitHub account with PAT

## Author

**Abdulaziz Al Heresh**  
📧 abdulaziz.harash@outlook.com  
🔗 [LinkedIn](https://linkedin.com/in/abdulazizheresh)  
🌐 [Portfolio](https://azizharash.com)

## License

MIT License - See LICENSE file

---

*Last Updated: October 2025*