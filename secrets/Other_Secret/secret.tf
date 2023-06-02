resource "aws_secretsmanager_secret" "avs_config" {
  name = "avs_config_4"

  tags = {
    environment = "Paula",
    service     = "avs"
  }
}

resource "aws_secretsmanager_secret_version" "avs_config" {
  secret_id = aws_secretsmanager_secret.avs_config.id
  secret_string = jsonencode({
    cognito_user_pool_id            = var.cognito_id
    cognito_user_pool_id_web         = var.cognito_web
    paulina = "paulina"

  })
}