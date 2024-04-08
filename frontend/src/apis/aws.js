import { AWS_API_KEY, GET_PRESIGNED_S3_URL, POST_SONG_METADATA_URL } from '@env';
import { Alert } from 'react-native';

/**
 * Retrieves a presigned S3 URL from the API.
 * @returns {Promise<Object|null>} The presigned S3 URL response object, or null if an error occurred.
 */
export async function getPresignedS3Url() {
    try {
        // Make a GET request to the API
        const response = await fetch(GET_PRESIGNED_S3_URL, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json',
                'x-api-key': AWS_API_KEY,
            },
        });
        // Get the JSON response
        let json = await response.json();
        // If the status code is not 200, throw an error
        if (json.statusCode !== 200) throw new Error(json.message || "Failed to fetch presigned URL");
        // Otherwise return the url
        return { url: json.body.url, key: json.body.key };
    }
    catch (err) {
        // Log the error to the console
        console.error(err);
        // Show an alert to the user with an error message
        Alert.alert('Error', `Failed to fetch presigned URL. Reason: ${err}`);
        // Return null to indicate an error occurred
        return null;
    }
}

/**
 * Uploads a file to S3 using a presigned URL.
 * @param {string} presignedUrl - The presigned URL for uploading the file.
 * @param {File} file - The file to be uploaded.
 * @returns {Promise<boolean>} - A promise that resolves to true if the file is uploaded successfully, or false otherwise.
 */
export async function uploadFileToS3(presignedUrl, blob) {
    try {
        // Make a PUT request to the presigned URL
        const response = await fetch(presignedUrl, {
            method: 'PUT',
            headers: {
                'Content-Type': 'audio/*',
            },
            body: blob
        });
        // If the status code is not 200, throw an error
        if (response.status !== 200) throw new Error(json.message || "Failed to upload file to S3");
        // Otherwise return true
        return true;
    }
    catch (err) {
        // Log the error to the console
        console.error(err);
        // Show an alert to the user with an error message
        Alert.alert('Error', `Failed to upload file to S3. Reason: ${err}`);
        // Return null to indicate an error occurred
        return null;
    }
}

export async function uploadMetadataToDb(s3Key, user_id, title, album, genre, artist, year) {
    // Set the metadata to be sent to AWS
    const metadata = { metadata_id: s3Key, user_id, title, album, genre, artist, year }
    // If the userId is an admin, add for_game = true
    if (user_id === "Admin") metadata.for_game = true;
    // Put the body into the format expected by the AWS Lambda function (uploadFileWithMetadata)
    let body = JSON.stringify(metadata);
    // Print message to console
    console.log(`Uploading metadata to database with body: ${body}`);
    try {
        // Make a POST request to the API
        const response = await fetch(POST_SONG_METADATA_URL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'x-api-key': AWS_API_KEY
            },
            body: body
        });
        // If the status code is not 200, throw an error
        if (response.status !== 200) throw new Error(json.message || "Failed to upload metadata to database");
        // Return true to indicate metadata successfully uploaded
        return true;
    }
    catch (err) {
        // Log the error to the console
        console.error(err);
        // Show an alert to the user with an error message
        Alert.alert('Error', `Failed to upload metadata to database. Reason: ${err}`);
        // Return null to indicate an error occurred
        return null;
    }
}

export async function getUserSongs(user_id) {
    // Put the body into the format expected by the AWS Lambda function (getUserSongs)
    let body = JSON.stringify({ user_id });
    // Print message to console
    console.log(`Getting user songs with body: ${body}`);
    try {
        // Make a POST request to the API
        const response = await fetch(GET_USER_SONGS_URL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'x-api-key': AWS_API_KEY
            },
            body: body
        });
        // If the status code is not 200, throw an error
        if (response.status !== 200) throw new Error(json.message || "Failed to get user songs");
        // Get the JSON response
        let json = await response.json();
        // Return the songs
        return json;
    }
    catch (err) {
        // Log the error to the console
        console.error(err);
        // Show an alert to the user with an error message
        Alert.alert('Error', `Failed to get user songs. Reason: ${err}`);
        // Return null to indicate an error occurred
        return null;
    }
}