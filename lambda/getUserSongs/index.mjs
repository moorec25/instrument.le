// Import necessary AWS SDK clients and commands
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, QueryCommand } from "@aws-sdk/lib-dynamodb";
import { GetObjectCommand, S3Client } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

export const handler = async (event) => {
    try {
        // Attempt to print the parameters
        console.log(event.body);
        // Parse the event body from string to JSON
        let params = JSON.parse(event.body);
        // Hardcode region
        const region = "us-east-1";
        // Hardcode bucket
        const bucket = "instrumentle-audio-files-full";
        // Create a new DynamoDB DocumentClient
        const dbClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region }));
        const s3Client = new S3Client({ region });
        // Define the query parameters
        const queryParams = {
            TableName: "instrumentle-song-metadata",
            IndexName: "user_id-index",
            KeyConditionExpression: "user_id = :userId",
            ExpressionAttributeValues: {
                ":userId": params.user_id,
            },
        };
        // Perform the query operation
        const queryResult = await dbClient.send(new QueryCommand(queryParams));
        // Extract items from the query result
        const items = queryResult.Items || [];
        // Array of objects to hold user songs and metadata
        const userSongList = [];
        // Go through each item and get the presigned URLs
        for (let i = 0; i < items.length; i++) {
            // Create the object to hold all information
            const userSong = {};
            // Append song metadata
            userSong.timestamp = items[i].timestamp;
            userSong.title = items[i].title;
            userSong.artist = items[i].artist;
            userSong.album = items[i].album;
            userSong.year = items[i].year;
            userSong.genre = items[i].genre;
            // If there are S3 keys, get the presigned URLs
            if (items[i].s3_drums_key) {
                const command = new GetObjectCommand({ Bucket: bucket, Key: items[i].s3_drums_key });
                userSong.drums_url = await getSignedUrl(s3Client, command, { expiresIn: 3600 });
            }
            if (items[i].s3_vocals_key) {
                const command = new GetObjectCommand({ Bucket: bucket, Key: items[i].s3_vocals_key });
                userSong.vocals_url = await getSignedUrl(s3Client, command, { expiresIn: 3600 });
            }
            if (items[i].s3_bass_key) {
                const command = new GetObjectCommand({ Bucket: bucket, Key: items[i].s3_bass_key });
                userSong.bass_url = await getSignedUrl(s3Client, command, { expiresIn: 3600 });
            }
            if (items[i].s3_other_key) {
                const command = new GetObjectCommand({ Bucket: bucket, Key: items[i].s3_other_key });
                userSong.other_url = await getSignedUrl(s3Client, command, { expiresIn: 3600 });
            }
            // If there is album art, get the presigned URL
            if (items[i].album_art_url) userSong.album_art_url = items[i].album_art_url;
            // Append the object to the list
            userSongList.push(userSong);
        }
        return {
            statusCode: 200,
            body: JSON.stringify(userSongList),
        };
    } catch (error) {
        console.error("Query operation error:", error);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: "Failed to query items" }),
        };
    }
};