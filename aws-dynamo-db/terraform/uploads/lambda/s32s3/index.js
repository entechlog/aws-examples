const AWS = require('aws-sdk');
const s3 = new AWS.S3();

exports.handler = async (event) => {
    console.log('Start copy');
    const sourceBucket = process.env.SOURCE_BUCKET;
    const destinationBucket = process.env.DESTINATION_BUCKET;
    const outputPath = process.env.OUTPUT_PATH; // Provided via environment variable

    try {
        for (const record of event.Records) {
            const manifestKey = record.s3.object.key;
            console.log(`Processing manifest file: ${manifestKey}`);

            // Fetch and parse the manifest file
            const manifestData = await s3.getObject({
                Bucket: sourceBucket,
                Key: manifestKey
            }).promise();

            const manifestContent = manifestData.Body.toString('utf-8');
            // Split the manifest content into lines, each representing a JSON object
            const fileInfos = manifestContent.trim().split('\n').map(line => JSON.parse(line));

            for (const fileInfo of fileInfos) {
                const key = fileInfo.dataFileS3Key;
                const parts = key.split('/');
                // Correctly extract the event_name as the first part of the path
                const event_name = parts[0]; // Adjusted to correctly extract event_name

                const fileName = parts[parts.length - 1]; // Extract the filename
                // Construct the new destination key with correct event_name
                const destinationKey = `${outputPath}event_name=${event_name}/${fileName}`;

                // Step to empty the directory before copying the new file
                const listParams = {
                    Bucket: destinationBucket,
                    Prefix: `${outputPath}event_name=${event_name}/`
                };

                const listedObjects = await s3.listObjectsV2(listParams).promise();

                if (listedObjects.Contents.length > 0) {
                    const deleteParams = {
                        Bucket: destinationBucket,
                        Delete: { Objects: listedObjects.Contents.map(({ Key }) => ({ Key })) }
                    };
                    await s3.deleteObjects(deleteParams).promise();
                    console.log(`Emptied directory: ${listParams.Prefix}`);
                }

                // Proceed to copy the file
                try {
                    await s3.copyObject({
                        CopySource: encodeURIComponent(`${sourceBucket}/${key}`),
                        Bucket: destinationBucket,
                        Key: destinationKey
                    }).promise();

                    console.log(`Successfully copied to ${destinationBucket}/${destinationKey}`);
                } catch (copyError) {
                    console.error(`Error copying ${key}: ${copyError.message}`);
                }
            }
        }
        return { statusCode: 200, body: 'Copy operation completed.' };
    } catch (err) {
        console.error(`An error occurred during the copy operation: ${err.message}`);
        return { statusCode: 500, body: 'An error occurred during the copy operation.' };
    }
};
