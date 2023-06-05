terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.55.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-2"
}
module "securitygroups" {
    source = "../terraform-rds/securitygroups"
    vpc_id = module.vpc.vpc_id
  
}

module vpc {
    source = "../terraform-rds/vpc"
    rds_security_group_id     = module.securitygroups.security_group_rds_id
    bastion_security_group_id = module.securitygroups.security_group_bastion_id
}

module "rds" {
    depends_on = [
      module.vpc
    ]
    source = "../terraform-rds/rds"
    rds_subnet_ids = [module.vpc.private_subnet_1, module.vpc.private_subnet_2]
    ec2_subnet_id_1 = module.vpc.private_subnet_1
    rds_security_group_id     = module.securitygroups.security_group_rds_id
    bastion_security_group_id = module.securitygroups.security_group_bastion_id
  
}