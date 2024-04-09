import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, UpdateCommand  } from '@aws-sdk/lib-dynamodb';

export const handler = async (event) => {
    try {
        // Attempt to print the parameters
        console.log(event.body);
        // Parse the event body from string to JSON
        let params = JSON.parse(event.body);
        // Create a new DynamoDB client
        const client = DynamoDBDocumentClient.from(new DynamoDBClient({ }));
        // Create update expression depending on if this song is in the game
        // Update only specified fields in the item
        let updateParams = {
            TableName: 'instrumentle-song-metadata',
            Key: {
                metadata_id: `${params.s3_key}.wav`,
            },
            UpdateExpression: 'set s3_bass_key = :bass, s3_drums_key = :drums, s3_other_key = :other, s3_vocals_key = :vocals, s3_2layer_key = :layer2, s3_3layer_key = :layer3, s3_keys_present = :keys_present, in_game = :in_game, #pr = :processed',
            ExpressionAttributeValues: {
                ':bass': `${params.s3_key}-bass.wav`,
                ':drums': `${params.s3_key}-drums.wav`,
                ':other': `${params.s3_key}-other.wav`,
                ':vocals': `${params.s3_key}-vocals.wav`,
                ':layer2': (params.for_game) ? `${params.s3_key}-2layer.wav` : "",
                ':layer3': (params.for_game) ? `${params.s3_key}-3layer.wav` : "",
                ':keys_present': (params.for_game) ? 1 : 0,
                ':in_game': (params.for_game) ? 1 : 0,
                ':processed': 1,
            },
            ExpressionAttributeNames: {
                '#pr': 'processed'  // Substitute for the reserved word 'processed'
            },
            ReturnValues: "UPDATED_NEW"
        };

        let updateRes = await client.send(new UpdateCommand(updateParams));
        // Print response to console
        console.log(updateRes);
        // Return a 200 response
        return {
            statusCode: 200,
            body: 'Metadata updated successfully',
        };
    }
    catch (err) {
        // Log a message to the console for CloudWatch
        console.log(err)
        return {
            statusCode: 500,
            body: err.toString(),
        };
    }
};