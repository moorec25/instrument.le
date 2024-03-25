import requests
import os

class AwsHelper:
    
    def __init__(self) -> None:
        pass
    
    def download_file_from_s3(self, s3_key: str) -> str | None:
        """
        This function downloads a file from S3 and returns the local file path.
        """
        # Use requests library to query Lambda to get presigned URL
        presignUrl = os.environ['GET_PRESIGNED_URL_DOWNLOAD']
        awsApiKey = os.environ['AWS_API_KEY']
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
            # Return the absolute path of the local file
            return os.path.abspath(file_name)
        # Otherwise the request failed
        return None
    
    def upload_tracks_to_s3(self, file_paths: list) -> None:
        """
        This function uploads the separated tracks to S3.
        """
        pass
    
if __name__ == '__main__':
    awsHelper = AwsHelper()
    filepath = awsHelper.download_file_from_s3("1710203805731-mwxf7b89dde.wav")
    print(filepath)