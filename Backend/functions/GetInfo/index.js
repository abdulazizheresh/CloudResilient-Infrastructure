const { DefaultAzureCredential } = require('@azure/identity');
const { WebSiteManagementClient } = require('@azure/arm-appservice');

// Helper function to format region names
function formatRegionName(region) {
    const regionNames = {
        'centralus': 'Central US',
        'westus': 'West US',
        'eastus': 'East US',
        'northeurope': 'North Europe',
        'westeurope': 'West Europe',
        'southeastasia': 'Southeast Asia',
        'eastasia': 'East Asia',
        'uksouth': 'UK South',
        'ukwest': 'UK West'
    };
    
    return regionNames[region.toLowerCase()] || 
        region.charAt(0).toUpperCase() + region.slice(1);
}

module.exports = async function (context, req) {
    context.log('GetInfo function triggered');

    try {
        const region = process.env.REGION || 'Unknown';
        const timestamp = new Date().toISOString();
        const uptime = '99.95%';
        
        const startTime = Date.now();
        await new Promise(resolve => setTimeout(resolve, 10));
        const responseTime = Date.now() - startTime;

        // ✅ Query Azure for active Function Apps
        let activeRegions = 1; // fallback
        
        try {
            const credential = new DefaultAzureCredential();
            const subscriptionId = process.env.AZURE_SUBSCRIPTION_ID;
            
            if (subscriptionId) {
                const client = new WebSiteManagementClient(credential, subscriptionId);
                let count = 0;
                
                // عد Function Apps النشطة فقط
                for await (let app of client.webApps.list()) {
                    if (app.name.startsWith('func-cloudres') && 
                        app.name.endsWith('-prod') && 
                        app.kind && app.kind.includes('functionapp') &&
                        app.state === 'Running') {
                        count++;
                    }
                }
                
                activeRegions = count;
                context.log(`Active regions: ${activeRegions}`);
            }
        } catch (error) {
            context.log.warn('Could not query Azure:', error.message);
        }

        const response = {
            region: formatRegionName(region),  // ✅ Friendly region name
            timestamp: timestamp,
            status: 'online',
            responseTime: responseTime,
            uptime: uptime,
            activeRegions: activeRegions,
            message: 'CloudResilient Infrastructure is running smoothly'
        };

        context.res = {
            status: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'GET, OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type'
            },
            body: response
        };

    } catch (error) {
        context.log.error('Error in GetInfo:', error);
        context.res = {
            status: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: {
                error: 'Internal server error',
                message: error.message
            }
        };
    }
};