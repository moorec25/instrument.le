import requests
import os
from dotenv import dotenv_values
config = dotenv_values(".env")

class AwsHelper:
    
    def __init__(self) -> None:
        pass
    
    def download_file_from_s3(self, s3_key: str) -> str | None:
        """
        This function downloads a file from S3 and returns the local file path.
        """
        print(f"Downloading file {s3_key} from S3...")
        # Use requests library to query Lambda to get presigned URL
        presignUrl = config['GET_PRESIGNED_URL_DOWNLOAD']
        awsApiKey = config['AWS_API_KEY']
        # Assert that presigned URL and API key are not None
        assert presignUrl is not None
        assert awsApiKey is not None
        # Send post request to Lambda function
        response = requests.post(presignUrl, headers = { 'x-api-key': awsApiKey }, json = { "key": s3_key })
        # Get the response code which will indicate success or failure
        responseCode = response.status_code
        # If the response code is 200, the request was successful
        if responseCode == 200:
            # Get the URL from the response
            url = response.json()['url']
            # Use requests library to download the file
            response = requests.get(url)
            # Get the file name from the S3 key
            file_name = s3_key.split('/')[-1]
            # Write the file to the local directory
            with open(file_name, 'wb') as file:
                file.write(response.content)
            # Print message to console
            print(f"Downloaded file {file_name} from S3")
            # Return the absolute path of the local file
            return os.path.abspath(file_name)
        # Otherwise the request failed
        return None
    
    def upload_tracks_to_s3(self, file_paths: list, s3_key: str, user_id: str, for_game: bool = False) -> None:
        """
        This function uploads the separated tracks to S3.
        """
        print("Uploading tracks to S3...")
        # Remove the ".wav" portion off the s3_key
        if s3_key.endswith(".wav"): s3_key = s3_key[:-4]
        # Use requests library to query Lambda to get presigned URL
        presignUrl = config['GET_PRESIGNED_URL_UPLOAD_SEPARATED']
        awsApiKey = config['AWS_API_KEY']
        # Assert that presigned URL and API key are not None
        assert presignUrl is not None
        assert awsApiKey is not None
        # Send post request to Lambda function
        response = requests.post(presignUrl, headers = { 'x-api-key': awsApiKey }, json = { "s3_key": s3_key, "for_game": for_game })
        # Get the response code which will indicate success or failure
        responseCode = response.status_code
        # If the response code is 200, the request was successful
        if responseCode == 200:
            # Get the URL from the response
            res = response.json()
            # Get each url
            bass_url = res['bass']
            drums_url = res['drums']
            other_url = res['other']
            vocals_url = res['vocals']
            layer2_url = res['2layer'] if '2layer' in res else None
            layer3_url = res['3layer'] if '3layer' in res else None
            # Iterate through the file paths
            for file_path in file_paths:
                # Get the file name from the file path
                file_name = file_path.split('/')[-1]
                # Use requests library to upload the file
                with open(file_path, 'rb') as file:
                    url = None
                    # Upload the file to the appropriate URL
                    if 'bass' in file_name:
                        url = bass_url
                    elif 'drums' in file_name:
                        url = drums_url
                    elif 'other' in file_name:
                        url = other_url
                    elif 'vocals' in file_name:
                        url = vocals_url
                    elif '2layer' in file_name:
                        url = layer2_url
                    elif '3layer' in file_name:
                        url = layer3_url
                    # Assert that the URL is not None
                    assert url is not None
                    # Upload file as binary data
                    response = requests.put(url, headers = { 'Content-Type': 'audio/*' }, data = file)
                # Print message to console
                print(f"Uploaded file {file_name} to S3")
            # Use requests library to query Lambda to update metadata in database
            updateUrl = config['UPDATE_METADATA']
            # Assert that update URL is not None
            assert updateUrl is not None
            # Send post request to Lambda function
            response = requests.post(updateUrl, headers = { 'x-api-key': awsApiKey }, json = { "s3_key": s3_key, "for_game": for_game })
            # Get the response code which will indicate success or failure
            responseCode = response.status_code
            # If the response code is 200, the request was successful
            if responseCode == 200:
                # Print message to console
                print("Updated metadata in database")
            else:
                # Print message to console
                print("Failed to update metadata in database")
                print(response)
        else:
            # Print message to console
            print("Failed to upload tracks to S3")
            print(response)
            
if __name__ == '__main__':
    awsHelper = AwsHelper()
    filepath = awsHelper.download_file_from_s3("1710203805731-mwxf7b89dde.wav")
    print(filepath)