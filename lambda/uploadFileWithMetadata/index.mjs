import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, PutCommand, QueryCommand } from '@aws-sdk/lib-dynamodb';
import { SQSClient, SendMessageCommand } from '@aws-sdk/client-sqs';

export const handler = async (event) => {
    try {
        // Attempt to print the parameters
        console.log(event.body);
        // Parse the event body from string to JSON
        let params = JSON.parse(event.body);
        // Create a new DynamoDB client
        const client = DynamoDBDocumentClient.from(new DynamoDBClient({ }));
        // Create a new param object
        let dynamoDbParams = {
            TableName: 'instrumentle-song-metadata',
            Item: {
                timestamp:          Date.now(),
                metadata_id:        params.metadata_id,
                user_id:            params.user_id,
                title:              params.title,
                album:              params.album,
                genre:              params.genre,
                artist:             params.artist,
                year:               params.year,
                album_art_url:      "",
                s3_bass_key:        "",
                s3_drums_key:       "",
                s3_other_key:       "",
                s3_vocals_key:      "",
                s3_2layer_key:      "",
                s3_3layer_key:      "",
                s3_keys_present:    0,
                in_game:            0,
                processed:          0
            }
        };
        // Attempt to put the item in the table
        let ddbRes = await client.send(new PutCommand(dynamoDbParams));
        // Guard clause to check if the item was not added
        if (ddbRes.$metadata.httpStatusCode !== 200) throw new Error('Failed to upload metadata');
        // Instantiate the SQS client
        const sqsClient = new SQSClient({ region: "us-east-1" });
        // Message body for SQS (adjust according to your needs)
        const messageBody = JSON.stringify({ 
            metadata_id: params.metadata_id, 
            user_id: params.user_id, 
            for_game: (params.for_game) ? true : false
        });
        // Parameters for sending a message to SQS
        const sqsParams = {
            QueueUrl: "https://sqs.us-east-1.amazonaws.com/238414682299/ProcessingQueue",
            MessageBody: messageBody,
        };
        // Send a message to SQS
        const sqsResponse = await sqsClient.send(new SendMessageCommand(sqsParams));
        console.log(`Message sent to SQS: ${sqsResponse.MessageId}`);
        // Return a 200 response
        return {
            statusCode: 200,
            body: 'Metadata uploaded successfully',
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