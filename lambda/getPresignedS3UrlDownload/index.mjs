import { GetObjectCommand, S3Client } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

export const handler = async (event) => {
    try {
        // Hardcode region
        const region = "us-east-1";
        // Hardcode bucket
        const bucket = "instrumentle-audio-files-full";
        // Parse the event body from string to JSON
        let params = JSON.parse(event.body);
        // Key is a combination of timestamp and a random UUID
        const key = params.key;
        // Create a client instance
        const client = new S3Client({ region });
        // Create instruction to put an object in the bucket
        const command = new GetObjectCommand({ Bucket: bucket, Key: key });
        // Get the presigned URL
        const url = await getSignedUrl(client, command, { expiresIn: 3600 });
        // Return the URL
        return {
            statusCode: 200,
            body: { url, key }
        };
    }
    catch (err) {
        // Log a message to the console for CloudWatch
        console.log(err)
        return {
            statusCode: 500,
            body: err,
        };
    }
};