import boto3

class AwsHelper:
    
    def __init__(self) -> None:
        pass
    
    def download_file_from_s3(self, s3_url: str) -> str:
        """
        This function downloads a file from S3 and returns the local file path.
        """
        
        # Return the absolute path of the local file
        return ""
    
    def upload_tracks_to_s3(self, file_paths: list) -> None:
        """
        This function uploads the separated tracks to S3.
        """
        pass