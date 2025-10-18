const { DefaultAzureCredential } = require('@azure/identity');
const { WebSiteManagementClient } = require('@azure/arm-appservice');

module.exports = async function (context, req) {
    try {
        const subscriptionId = process.env.AZURE_SUBSCRIPTION_ID;
        const currentRegion = process.env.REGION?.toLowerCase();
        const rgName = `rg-cloudres-compute-${currentRegion}-prod`;
        const funcName = `func-cloudres-${currentRegion}-prod`;
        
        // أرسل response أولاً
        context.res = {
            status: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: {
                success: true,
                message: `${currentRegion} will stop in 3 seconds...`,
                stoppedRegion: currentRegion
            }
        };
        
        // أوقف بعد 3 ثواني
        setTimeout(async () => {
            try {
                const credential = new DefaultAzureCredential();
                const client = new WebSiteManagementClient(credential, subscriptionId);
                await client.webApps.stop(rgName, funcName);
                context.log('Function app stopped successfully');
            } catch (err) {
                context.log.error('Stop failed:', err);
            }
        }, 3000);
        
    } catch (error) {
        context.log.error('Failover error:', error);
        context.res = {
            status: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: { 
                success: false,
                error: error.message 
            }
        };
    }
};