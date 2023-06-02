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
module cognito {
    source = "../secrets/secret_cognito"

  
}

module avs {
    source = "../secrets/Other_secret"
    cognito_id = module.cognito.cognito["cognito_user_pool_id"]
    cognito_web = module.cognito.cognito["cognito_user_pool_web_client_id"]
}