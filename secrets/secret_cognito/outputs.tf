output "cognito" {
    value = jsondecode(aws_secretsmanager_secret_version.cognito_user_pool_secret.secret_string)
}

