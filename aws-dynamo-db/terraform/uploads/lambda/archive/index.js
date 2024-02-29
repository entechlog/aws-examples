const AWS = require('aws-sdk');
const s3 = new AWS.S3();

exports.handler = async (event) => {
    console.log('Start copy');
    const sourceBucket = process.env.SOURCE_BUCKET;
    const destinationBucket = process.env.DESTINATION_BUCKET;
    const outputPath = process.env.OUTPUT_PATH; // Provided via environment variable

    try {
        for (const record of event.Records) {
            const key = record.s3.object.key;
            console.log(`Processing file: ${key}`); // Log the file name that triggered the event

            // Split the key into parts and find date components
            const parts = key.split('/');
            let year = parts.find(part => part.match(/^\d{4}$/));
            let month = parts.find(part => part.match(/^\d{2}$/) && parts.indexOf(part) === parts.indexOf(year) + 1);
            let day = parts.find(part => part.match(/^\d{2}$/) && parts.indexOf(part) === parts.indexOf(month) + 1);

            // Use current date as fallback
            if (!year || !month || !day) {
                console.log(`Date not found in the key: ${key}, using current date.`);
                const currentDate = new Date();
                year = currentDate.getFullYear().toString();
                month = ('0' + (currentDate.getMonth() + 1)).slice(-2); // JS months are 0-indexed
                day = ('0' + currentDate.getDate()).slice(-2);
            }

            // Assume event_name is the first part of the key
            const event_name = parts[0]; // Adjust based on actual key structure if needed
            const fileName = parts.pop(); // Extract the filename

            // Construct the destination key
            const destinationKey = `${outputPath}event_name=${event_name}/year=${year}/month=${month}/day=${day}/${fileName}`;

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
        return { statusCode: 200, body: 'Copy operation completed.' };
    } catch (err) {
        console.error(`An error occurred during the copy operation: ${err.message}`);
        return { statusCode: 500, body: 'An error occurred during the copy operation.' };
    }
};
