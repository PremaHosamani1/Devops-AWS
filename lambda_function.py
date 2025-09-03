import json
import boto3

sqs = boto3.client("sqs")
QUEUE_URL = None  # will be set via environment variable

def lambda_handler(event, context):
    global QUEUE_URL
    if not QUEUE_URL:
        import os
        QUEUE_URL = os.environ["QUEUE_URL"]

    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']

        message = {
            "bucket": bucket,
            "key": key
        }

        response = sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=json.dumps(message)
        )
        print(f"Sent message to SQS: {response['MessageId']}")

    return {"statusCode": 200, "body": "Message sent"}
