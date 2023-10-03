resource "aws_secretsmanager_secret" "replica_db_credentials" {
  # count = var.rds_enable_backend_replica ? 1 : 0
  name  = "avs_db_credentials_replica_host4"
}

resource "aws_secretsmanager_secret_version" "replica_db_json_credentials" {
  # count     = var.rds_enable_backend_replica ? 1 : 0
  secret_id = aws_secretsmanager_secret.replica_db_credentials.id
  secret_string = jsonencode({
    host = var.rds_enable_backend_replica ? "Paula" : ""

  })
}


