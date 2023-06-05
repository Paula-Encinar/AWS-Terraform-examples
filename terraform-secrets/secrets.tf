resource "random_password" "random_datagateway_recovery_key" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "datagateway_recovery_key1" {
  name = "powerbi_datagateway_recovery_key_paula1"

  tags = {
    environment = "paula"
  }
}

resource "aws_secretsmanager_secret_version" "datagateway_recovery_key1" {
  secret_id = aws_secretsmanager_secret.datagateway_recovery_key1.id
  secret_string = jsonencode({
    recovery_key             = random_password.random_datagateway_recovery_key.result

  })
}

output "key" {
    value = aws_secretsmanager_secret_version.datagateway_recovery_key1.arn
  
}

output "keystring" {
    value = aws_secretsmanager_secret_version.datagateway_recovery_key1.secret_string
    sensitive = true
  
}