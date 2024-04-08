from SongSeparator import SongSeparator 
from AwsHelper import AwsHelper
import boto3
import time
import json
from dotenv import dotenv_values

config = dotenv_values(".env")

# Initialize the SQS client
sqs = boto3.client(
    'sqs', 
    region_name = 'us-east-1',
    aws_access_key_id = config['AWS_ACCESS_KEY_ID'],
    aws_secret_access_key = config['AWS_SECRET_ACCESS_KEY'],
)

# URL for the SQS queue
queue_url = 'https://sqs.us-east-1.amazonaws.com/238414682299/ProcessingQueue'

# Initialize the helper classes
aw = AwsHelper()
ss = SongSeparator()

# This function is the main function that the FPGA should run.
# This polls the SQS (simple queue service) for incoming requests.
# The requests will contain the URL to the song to be separated.
def poll_sqs():
    while True:
        try:
            print("Polling...")
            # Recieve messages from the queue
            messages = sqs.receive_message(QueueUrl = queue_url, MaxNumberOfMessages = 1, WaitTimeSeconds = 20)
            # Go through each unprocessed message in the queue
            for message in messages.get('Messages', []):
                # Extract the S3 URL and metadata from the message body
                message_body = message['Body']
                # Print out the received message
                print(f"Received message: {message_body}")
                # Load the message body as a JSON object
                message_json = json.loads(message_body)
                # Extract fields from json
                s3_key = message_json["metadata_id"]
                user_id = message_json["user_id"]
                for_game = message_json["for_game"]
                # Download the full song from S3
                full_song_file_path = aw.download_file_from_s3(s3_key)
                # Assert that the file path is not None
                assert full_song_file_path is not None
                # Process the song on FPGA
                separated_file_paths = ss.separate_song(full_song_file_path, for_game)
                # Delete message from queue after processing
                sqs.delete_message(QueueUrl = queue_url, ReceiptHandle = message['ReceiptHandle'])
                # Upload the separated tracks to S3
                aw.upload_tracks_to_s3(separated_file_paths, s3_key, user_id, for_game)
            # Poll every few seconds
            print("Sleeping...")
            time.sleep(2)
        except Exception as err:
            print(err)

if __name__ == "__main__":
    poll_sqs()
