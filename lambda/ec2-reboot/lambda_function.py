import os
import boto3

def lambda_handler(event, context):
    instance_id_1 = os.environ.get('EC2_INSTANCE_ID')  # Replace with the actual environment variable name for instance 1

    ec2_client = boto3.client('ec2')

    response_1 = ec2_client.reboot_instances(InstanceIds=[instance_id_1])
    print("Response for instance 1:", response_1)

    instance_id_2 = os.environ.get('EC2_INSTANCE_ID_POWERBI', None)  # Get instance ID for instance 2, default to None if not found

    if instance_id_2:
        response_2 = ec2_client.reboot_instances(InstanceIds=[instance_id_2])
        print("Response for instance 2:", response_2)
    else:
        print("Environment variable 'EC2_INSTANCE_ID_POWERBI' not found. Skipping instance 2 restart.")
