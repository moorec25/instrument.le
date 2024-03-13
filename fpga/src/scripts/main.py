import boto3
import time

# Initialize the SQS client
sqs = boto3.client('sqs')
queue_url = 'https://sqs.us-east-1.amazonaws.com/238414682299/ProcessingQueue'

# This function is the main function that the FPGA should run.
# This polls the SQS (simple queue service) for incoming requests.
# The requests will contain the URL to the song to be separated.
def poll_sqs():
    while True:
        # Recieve messages from the queue
        messages = sqs.receive_message(QueueUrl = queue_url, MaxNumberOfMessages = 1, WaitTimeSeconds = 20)
        # Go through each unprocessed message in the queue
        for message in messages.get('Messages', []):
            # Extract the S3 URL and metadata from the message body
            message_body = message['Body']
            print(f"Received message: {message_body}")
            # Download the full song from S3
            full_song_file_path = download_file_from_s3(message_body)
            # Process the song on FPGA
            separated_file_paths = separate_song(full_song_file_path)
            # Delete message from queue after processing
            sqs.delete_message(QueueUrl = queue_url, ReceiptHandle = message['ReceiptHandle'])
            # Upload the separated tracks to S3
            upload_tracks_to_s3(separated_file_paths)

        time.sleep(2)  # Poll every few seconds

if __name__ == "__main__":
    poll_sqs()
