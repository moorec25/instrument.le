import { PutObjectCommand, S3Client } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

export const handler = async (event) => {
    // Hardcode region
    const region = "us-east-1";
    // Hardcode bucket
    const bucket = "instrumentle-audio-files-full";
    // Key is a combination of timestamp and a random UUID
    const key = `${Date.now()}-${Math.random().toString(36).substring(2, 15)}`;
    // Create a client instance
    const client = new S3Client({ region });
    // Create instruction to put an object in the bucket
    const command = new PutObjectCommand({ Bucket: bucket, Key: key });
    // Get the presigned URL
    const url = await getSignedUrl(client, command, { expiresIn: 3600 });
    // Return the URL
    return {
        statusCode: 200,
        body: { url, key }
    };
};