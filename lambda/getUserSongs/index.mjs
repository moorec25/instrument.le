// Import necessary AWS SDK clients and commands
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, QueryCommand } from "@aws-sdk/lib-dynamodb";

export const handler = async (event) => {
    // Attempt to print the parameters
    console.log(event.body);
    // Parse the event body from string to JSON
    let params = JSON.parse(event.body);
    // Create a new DynamoDB DocumentClient
    const client = DynamoDBDocumentClient.from(new DynamoDBClient({ region: "us-east-1" }));
    // Define the query parameters
    const queryParams = {
        TableName: "instrumentle-song-metadata",
        KeyConditionExpression: "user_id = :userId",
        ExpressionAttributeValues: {
            ":userId": params.user_id,
        },
    };
    try {
        // Perform the query operation
        const queryResult = await client.send(new QueryCommand(queryParams));
        // Extract items from the query result
        const items = queryResult.Items || [];
        // Return the items as the response
        return {
            statusCode: 200,
            body: JSON.stringify(items),
        };
    } catch (error) {
        console.error("Query operation error:", error);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: "Failed to query items" }),
        };
    }
};