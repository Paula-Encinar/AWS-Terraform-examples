output "replica_db_json_credentials_arn" {
  value = aws_secretsmanager_secret_version.replica_db_json_credentials.arn
  sensitive = false
}

output "replica_db_json_credentials" {
  value = aws_secretsmanager_secret_version.replica_db_json_credentials.secret_string
  sensitive = false
}