const AWS = require('aws-sdk');

exports.handler = async (event) => {
    console.log('Start exporting');
    const dynamodb = new AWS.DynamoDB();

    const todayDate = new Date().toISOString().slice(0, 10);
    const formattedDate = todayDate.replace(/-/g, "/");

    const s3Bucket = process.env.BUCKET_NAME;
    // const applicationName = process.env.APP_CODE;
    const tableArns = JSON.parse(process.env.TABLE_ARNS);

    for (const tableArn of tableArns) {
        const tableName = tableArn.split(':').pop().split('/').pop();       
        // const s3Prefix = `${applicationName}/${tableName}/${formattedDate}/`;
        const s3Prefix = `${tableName}/${formattedDate}/`;

        const params = {
            S3Bucket: s3Bucket,
            TableArn: tableArn,
            ExportFormat: 'DYNAMODB_JSON',
            S3Prefix: s3Prefix,
        };

        try {
            const exportResponse = await dynamodb.exportTableToPointInTime(params).promise();
            console.log(`Successfully extracted data for table ${tableName}: ${JSON.stringify(exportResponse)}`);
        } catch (err) {
            console.error(`Error extracting data for table ${tableName}: ${err}`);
        }
    }
};
