#datagateway.ps1
<powershell>

$PoshResponse = aws secretsmanager get-secret-value --secret-id powerbi_datagateway_recovery_key7_staging --query "SecretString" --output text --region eu-west-2

</powershell>
