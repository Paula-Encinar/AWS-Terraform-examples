resource "random_password" "random_admin_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}


resource "aws_secretsmanager_secret" "db_credentials" {
  name = "avs_db_credentials-5"

  tags = {
    environment = "Paula_test"
  }
}

resource "aws_secretsmanager_secret_version" "db_json_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username             = "db_user_admin"
    password             = random_password.random_admin_password.result
    engine               = aws_db_instance.primary_rds_instance.engine
    host                 = aws_db_instance.primary_rds_instance.address
    port                 = aws_db_instance.primary_rds_instance.port
    dbname               = aws_db_instance.primary_rds_instance.db_name
    dbInstanceIdentifier = aws_db_instance.primary_rds_instance.identifier
    old_host             = ""
  })
}

resource "aws_secretsmanager_secret_rotation" "rotation" {
	# secret_id through the secret_version so that it is deployed before setting up rotation
  secret_id           = aws_secretsmanager_secret_version.db_json_credentials.secret_id
  rotation_lambda_arn = aws_serverlessapplicationrepository_cloudformation_stack.rotate-stack.outputs.RotationLambdaARN

  rotation_rules {
    schedule_expression = 30
  }
}