resource "aws_secretsmanager_secret" "cognito_user_pool_secret" {
  name = "cognito_user_pool_secret4"
  tags = {
    Environment = "Paula"
  }
  tags_all = {
    Environment = "Paula"
  }
}

resource "aws_secretsmanager_secret_version" "cognito_user_pool_secret" {
  secret_id = aws_secretsmanager_secret.cognito_user_pool_secret.id
  secret_string = jsonencode({
    cognito_user_pool_id : "paula"
    cognito_user_pool_web_client_id : "paula1234"
    paulina = "paulina"
  })
  lifecycle {
    ignore_changes = all
  }
}
