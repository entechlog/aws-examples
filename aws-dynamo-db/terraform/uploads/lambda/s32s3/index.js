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

            // Determine unique event_names to clear directories once for each
            const eventNames = new Set(fileInfos.map(fileInfo => {
                const parts = fileInfo.dataFileS3Key.split('/');
                return parts[0]; // Assuming the event_name is the first part
            }));

            for (const event_name of eventNames) {
                // Empty the directory once for each unique event_name before copying files
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
            }

            // Now proceed to copy each file
            for (const fileInfo of fileInfos) {
                const key = fileInfo.dataFileS3Key;
                const parts = key.split('/');
                const event_name = parts[0]; // Extracting the event_name again for clarity
                const fileName = parts[parts.length - 1]; // Extract the filename
                const destinationKey = `${outputPath}event_name=${event_name}/${fileName}`;

                // Copy the file
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
