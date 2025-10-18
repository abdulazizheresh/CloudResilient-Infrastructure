const sql = require('mssql');

module.exports = async function (context, req) {
    context.log('IncrementVisitor function triggered');

    try {
        const connectionString = process.env.SQL_CONNECTION_STRING;
        const region = process.env.REGION || 'Unknown';

        // Connect to database
        await sql.connect(connectionString);

        // Execute stored procedure to increment
        const result = await sql.query`EXEC sp_IncrementVisitor`;

        if (result.recordset && result.recordset.length > 0) {
            const data = result.recordset[0];

            context.res = {
                status: 200,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Methods': 'POST, OPTIONS',
                    'Access-Control-Allow-Headers': 'Content-Type'
                },
                body: {
                    success: true,
                    visitorCount: data.VisitorCount,
                    lastUpdated: data.LastUpdated,
                    region: data.Region,
                    currentRegion: region,
                    message: 'Visitor count incremented successfully'
                }
            };
        } else {
            context.res = {
                status: 500,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                body: {
                    success: false,
                    error: 'Failed to increment visitor count'
                }
            };
        }

        await sql.close();

    } catch (error) {
        context.log.error('Error in IncrementVisitor:', error);
        context.res = {
            status: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: {
                success: false,
                error: 'Database connection error',
                message: error.message
            }
        };
    }
};