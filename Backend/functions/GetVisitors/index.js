const sql = require('mssql');

module.exports = async function (context, req) {
    context.log('GetVisitors function triggered');

    try {
        const connectionString = process.env.SQL_CONNECTION_STRING;
        const region = process.env.REGION || 'Unknown';

        // Connect to database
        await sql.connect(connectionString);

        // Execute stored procedure
        const result = await sql.query`EXEC sp_GetVisitors`;

        if (result.recordset && result.recordset.length > 0) {
            const data = result.recordset[0];

            context.res = {
                status: 200,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Methods': 'GET, OPTIONS',
                    'Access-Control-Allow-Headers': 'Content-Type'
                },
                body: {
                    visitorCount: data.VisitorCount,
                    lastUpdated: data.LastUpdated,
                    region: data.Region,
                    currentRegion: region,
                    dbStatus: 'connected'
                }
            };
        } else {
            context.res = {
                status: 404,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                body: {
                    error: 'No visitor data found'
                }
            };
        }

        await sql.close();

    } catch (error) {
        context.log.error('Error in GetVisitors:', error);
        context.res = {
            status: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: {
                error: 'Database connection error',
                message: error.message,
                dbStatus: 'disconnected'
            }
        };
    }
};