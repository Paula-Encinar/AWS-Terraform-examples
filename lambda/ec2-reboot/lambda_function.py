import boto3
import json
import requests
from msal import PublicClientApplication
import os

def lambda_handler(event, context):
    environment = os.environ.get('ENVIRONMENT')
    # AWS Secrets Manager configuration
    secret_name = f'powerbi_datagateway_recovery_key_{environment}'  # Name of the existing secret

    # Name of the specific gateway to retrieve
    target_gateway_name = "DataGateway_testing_Paula"

    # EC2 instance ID to restart (replace with your instance ID)
    instance_id_ms_export = os.environ.get('EC2_INSTANCE_ID_MS_EXPORT')
    instance_id_powerbi = os.environ.get('EC2_INSTANCE_ID_POWERBI')

    # Create an AWS Secrets Manager client
    secretsmanager = boto3.client('secretsmanager')

    # Retrieve the existing secret
    existing_secret = secretsmanager.get_secret_value(SecretId=secret_name)
    existing_secret_dict = json.loads(existing_secret['SecretString'])

    # Power BI API configuration
    secret_azure_name = "AzurePowerBI"
    secret_powerBI_name = "powerbi"
    gateways_endpoint = 'https://api.powerbi.com/v1.0/myorg/gateways'
    scope = ['https://analysis.windows.net/powerbi/api/.default']

    # Retrieve the secret Azure values
    response = secretsmanager.get_secret_value(SecretId=secret_azure_name)
    secret_string = response['SecretString']
    secret_data = json.loads(secret_string)

    client_id = secret_data['AzureApplicationId']
    client_secret = secret_data['AzureClientSecret']
    tenant_id = secret_data['AzureTenant']

    # Access the Azure secret Power BI values
    response = secretsmanager.get_secret_value(SecretId=secret_powerBI_name)
    secret_string = response['SecretString']
    secret_data = json.loads(secret_string)

    username = secret_data['user']
    password = secret_data['password']

    # Authenticate and obtain an access token
    app = PublicClientApplication(
        client_id=client_id,
        authority="https://login.microsoftonline.com/" + tenant_id
    )

    acquire_tokens_result = app.acquire_token_by_username_password(
        username=username,
        password=password,
        scopes=scope
    )

    if 'error' in acquire_tokens_result:
        return {
            'statusCode': 500,
            'body': acquire_tokens_result['error']
        }
    else:
        access_token = acquire_tokens_result['access_token']
        headers = {'Authorization': f'Bearer {access_token}', 'Content-Type': 'application/json'}

        # Make a request to the Power BI API to retrieve gateway information
        response = requests.get(gateways_endpoint, headers=headers)
        response.raise_for_status()
        gateways = response.json()

        # Find the gateway with the specified name
        for gateway in gateways['value']:
            if isinstance(gateway, dict) and gateway.get("name") == target_gateway_name:
                # Extract the exponent and modulus from the public key
                gateway_exponent = gateway['publicKey']['exponent']
                gateway_modulus = gateway['publicKey']['modulus']

                # Store the exponent and modulus in the existing secret
                existing_secret_dict['gateway_exponent'] = gateway_exponent
                existing_secret_dict['gateway_modulus'] = gateway_modulus

                # Update the secret with the new keys and values
                response = secretsmanager.put_secret_value(
                    SecretId=secret_name,
                    SecretString=json.dumps(existing_secret_dict)
                )

                # Restart the specified EC2 instance
                ec2_client = boto3.client('ec2')

                if instance_id_ms_export is not None:

                  response_ms_export = ec2_client.reboot_instances(InstanceIds=[instance_id_ms_export])
                  print("Response for ms_export instance:", response_ms_export)

                else:
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

    return {
        'statusCode': 404,
        'body': 'Gateway not found or public key not available.'
    }
