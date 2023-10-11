import boto3
import json
import requests
from msal import PublicClientApplication
import os

def lambda_handler(event, context):

    # Restart the specified EC2 instance
    ec2_client = boto3.client('ec2')
    instance_id_powerbi = os.environ.get('EC2_INSTANCE_ID_MS_EXPORT')
    print("Environment variable 'EC2_INSTANCE_ID_MS_EXPORT' not found. Skipping instance 1 restart.")

    if instance_id_powerbi is not None:
        response_powerbi = ec2_client.reboot_instances(InstanceIds=[instance_id_powerbi])
        print("Response for powerbi instance:", response_powerbi)
    else:
        print("Environment variable 'EC2_INSTANCE_ID_POWERBI' not found. Skipping instance 2 restart.")

    return {
        'statusCode': 200,
        'body': 'Exponent and modulus values added to the secret. EC2 instance restart initiated.',
    }

