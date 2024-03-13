import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, QueryCommand } from '@aws-sdk/lib-dynamodb';
import { GetObjectCommand, S3Client } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

export const handler = async (event) => {
    try {
        // Create a new DynamoDB client
        const dbClient = DynamoDBDocumentClient.from(new DynamoDBClient({ }));
        // Query metadata table for songs that are allowed to be used for the game
        const query = {
            TableName: 'instrumentle-song-metadata',
            IndexName: 'in_game-s3_keys_present-index',
            KeyConditionExpression: 'in_game = :inGame AND s3_keys_present = :s3KeysPresent',
            ExpressionAttributeValues: {
                ':inGame': 1,
                ':s3KeysPresent': 1
            }
        };
        // Attempt to get the items from the table
        const queryResult = await dbClient.send(new QueryCommand(query));
        // Guard clause in case there are no qualifying items from the index
        if (queryResult.Items.length === 0) {
            return {
                statusCode: 200,
                body: JSON.stringify({ message: "No items found" }),
            };
        }
        // Pick a random index from the item list to be used for the game
        const randomIndex = Math.floor(Math.random() * queryResult.Items.length);
        // Get all the S3 keys from the item at the random index
        const fullKey = queryResult.Items[randomIndex].metadata_id;
        const bassKey = queryResult.Items[randomIndex].s3_bass_key;
        const drumKey = queryResult.Items[randomIndex].s3_drums_key;
        const vocalKey = queryResult.Items[randomIndex].s3_vocals_key;
        const otherKey = queryResult.Items[randomIndex].s3_other_key;
        // Guard clause in case any key is not present 
        if (!fullKey || !bassKey || !drumKey || !vocalKey || !otherKey) {
            return {
                statusCode: 200,
                body: JSON.stringify({ message: "One or more keys missing" }),
            };
        }
        // Region and bucket of the S3 bucket
        const region = "us-east-1";
        const bucket = "instrumentle-audio-files-full";
        // Create client for the S3 bucket
        const s3Client = new S3Client({ region });
        // Create instruction to put an object in the bucket
        const fullCommand = new GetObjectCommand({ Bucket: bucket, Key: fullKey });
        const bassCommand = new GetObjectCommand({ Bucket: bucket, Key: bassKey });
        const drumCommand = new GetObjectCommand({ Bucket: bucket, Key: drumKey });
        const vocalCommand = new GetObjectCommand({ Bucket: bucket, Key: vocalKey });
        const otherCommand = new GetObjectCommand({ Bucket: bucket, Key: otherKey });
        // Get a presigned URL for each key
        let [full_url, bass_url, drum_url, vocal_url, other_url] = await Promise.all([
            getSignedUrl(s3Client, fullCommand, { expiresIn: 3600 }),
            getSignedUrl(s3Client, bassCommand, { expiresIn: 3600 }),
            getSignedUrl(s3Client, drumCommand, { expiresIn: 3600 }),
            getSignedUrl(s3Client, vocalCommand, { expiresIn: 3600 }),
            getSignedUrl(s3Client, otherCommand, { expiresIn: 3600 }),
        ]);
        // Create an object to attach to the response
        const urlObj = { full_url, bass_url, drum_url, vocal_url, other_url };
        // Attach to the object at the random index
        queryResult.Items[randomIndex].urls = urlObj;
        // Return the object
        return {
            statusCode: 200,
            body: JSON.stringify(queryResult.Items[randomIndex])
        };
    }
    catch (err) {
        return {
            statusCode: 500,
            body: err,
        };
    }
}