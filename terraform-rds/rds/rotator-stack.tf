# find the details by id
data "aws_serverlessapplicationrepository_application" "rotator" {
  application_id = "arn:aws:serverlessrepo:us-east-1:297356227824:applications/SecretsManagerRDSPostgreSQLRotationSingleUser"
}

data "aws_partition" "current" {}
data "aws_region" "current" {}

# deploy the cloudformation stack
resource "aws_serverlessapplicationrepository_cloudformation_stack" "rotate-stack" {
  name             = "rotator-postgres-secret"
  application_id   = data.aws_serverlessapplicationrepository_application.rotator.application_id
  semantic_version = data.aws_serverlessapplicationrepository_application.rotator.semantic_version
  capabilities     = data.aws_serverlessapplicationrepository_application.rotator.required_capabilities

  parameters = {
		# secrets manager endpoint
    endpoint            = "https://secretsmanager.${data.aws_region.current.name}.${data.aws_partition.current.dns_suffix}"
		# a random name for the function
    functionName        = "rotator-postgres-secret"
		# deploy in the first subnet
    vpcSubnetIds        = var.ec2_subnet_id_1
		# attach the security group so it can communicate with the other componets
    vpcSecurityGroupIds = var.rds_security_group_id
  }
}