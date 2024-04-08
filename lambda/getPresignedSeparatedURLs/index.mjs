import { PutObjectCommand, S3Client } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

export const handler = async (event) => {
    // Attempt to print the parameters
    console.log(event.body);
    // Parse the event body from string to JSON
    let params = JSON.parse(event.body);
    // Hardcode region
    const region = "us-east-1";
    // Hardcode bucket
    const bucket = "instrumentle-audio-files-full";
    // Key is a combination of timestamp and a random UUID
    const key1 = `${params.s3_key}_bass.wav`;
    const key2 = `${params.s3_key}_drums.wav`;
    const key3 = `${params.s3_key}_other.wav`;
    const key4 = `${params.s3_key}_vocals.wav`;
    const key5 = `${params.s3_key}_2layer.wav`;
    const key6 = `${params.s3_key}_3layer.wav`;
    // Create a client instance
    const client = new S3Client({ region });
    // Create instruction to put an object in the bucket
    const command1 = new PutObjectCommand({ Bucket: bucket, Key: key1 });
    const command2 = new PutObjectCommand({ Bucket: bucket, Key: key2 });
    const command3 = new PutObjectCommand({ Bucket: bucket, Key: key3 });
    const command4 = new PutObjectCommand({ Bucket: bucket, Key: key4 });
    // Get the presigned URL
    const url1 = await getSignedUrl(client, command1, { expiresIn: 3600 });
    const url2 = await getSignedUrl(client, command2, { expiresIn: 3600 });
    const url3 = await getSignedUrl(client, command3, { expiresIn: 3600 });
    const url4 = await getSignedUrl(client, command4, { expiresIn: 3600 });
    // Create object
    const obj = {
      "bass": url1,
      "drums": url2,
      "other": url3,
      "vocals": url4
    }
    // If this is the game, add 2 and 3 layer
    if (params.for_game) {
      // Create instructions
      const command5 = new PutObjectCommand({ Bucket: bucket, Key: key5 });
      const command6 = new PutObjectCommand({ Bucket: bucket, Key: key6 });
      // Get the presigned URL
      const url5 = await getSignedUrl(client, command5, { expiresIn: 3600 });
      const url6 = await getSignedUrl(client, command6, { expiresIn: 3600 });
      // Append to object
      obj["2layer"] = url5
      obj["3layer"] = url6
    }
    // Return the URL
    return {
        statusCode: 200,
        body: JSON.stringify(obj)
    };
};