const AWS = require('aws-sdk');

exports.handler = async (event) => {
    console.log('Start exporting');

    // Assume the DynamoDB access role
    const sts = new AWS.STS();
    const assumedRole = await sts.assumeRole({
        RoleArn: process.env.ROLE_ARN,
        RoleSessionName: 'dynamoDBExportSession',
    }).promise();

    // Use the temporary security credentials to create a new DynamoDB client
    const dynamodb = new AWS.DynamoDB({
        accessKeyId: assumedRole.Credentials.AccessKeyId,
        secretAccessKey: assumedRole.Credentials.SecretAccessKey,
        sessionToken: assumedRole.Credentials.SessionToken,
    });

    const todayDate = new Date().toISOString().slice(0, 10);
    const formattedDate = todayDate.replace(/-/g, "/");

    const s3Bucket = process.env.BUCKET_NAME;
    const tableArns = JSON.parse(process.env.TABLE_ARNS);

    for (const tableArn of tableArns) {
        const tableName = tableArn.split(':').pop().split('/').pop();       
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
