output "security_group_rds_id" {
  value = aws_security_group.rds.id
}

output "security_group_bastion_id" {
  value = aws_security_group.sg.id
}
