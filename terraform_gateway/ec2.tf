resource "aws_iam_instance_profile" "dev-resources-iam-profile" {
  name = "ec2_profile"
  role = aws_iam_role.dev-resources-iam-role.name
}

resource "aws_iam_role" "dev-resources-iam-role" {
  name        = "dev-ssm-role"
  description = "The role for the developer resources EC2"
  assume_role_policy = <<EOF
  {
  "Version": "2012-10-17",
  "Statement": {
  "Effect": "Allow",
  "Principal": {"Service": "ec2.amazonaws.com"},
  "Action": "sts:AssumeRole"
  }
  }
  EOF
  tags = {
    Environment = "development"
  }
}


data "aws_iam_policy" "ec2_ssm_policy"{
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_role_policy_attachment" "dev-resources-ssm-policy" {
  role       = aws_iam_role.dev-resources-iam-role.name
  policy_arn = data.aws_iam_policy.ec2_ssm_policy.arn

}

data "aws_iam_policy" "ec2_secret_manager"{
  arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "dev-resources-ssecret_manager-policy" {
  role       = aws_iam_role.dev-resources-iam-role.name
  policy_arn = data.aws_iam_policy.ec2_secret_manager.arn

}


resource "random_password" "random_datagateway_recovery_key1" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}


resource "aws_secretsmanager_secret" "datagateway_recovery_key1" {
  name = "powerbi_datagateway_recovery_key7_${var.long_environment}"

  tags = {
    environment = var.long_environment
  }
}



resource "aws_secretsmanager_secret_version" "datagateway_recovery_key1" {
  secret_id = aws_secretsmanager_secret.datagateway_recovery_key1.id
  secret_string = jsonencode({
    recovery_key             = random_password.random_datagateway_recovery_key1.result

  })
}

data "aws_secretsmanager_secret" "azurePowerBI" {
  name = "AzurePowerBI"
}

data "aws_secretsmanager_secret_version" "azurePowerBI" {
  secret_id = data.aws_secretsmanager_secret.azurePowerBI.arn

}

data "template_file" "user_data_bastion" {
  template = file("${path.module}/template/datagateway2.ps1")
    vars = {
      environment = var.long_environment
      azurePowerBI = data.aws_secretsmanager_secret_version.azurePowerBI.arn
      datagateway_recovery_key = aws_secretsmanager_secret_version.datagateway_recovery_key1.arn
  }
}


resource "aws_instance" "app_server" {
  ami           = "ami-073bb7464cc51df7c"
  instance_type = "t2.micro"
  key_name = "windowsgateway"
  iam_instance_profile = aws_iam_instance_profile.dev-resources-iam-profile.name
  user_data                   = data.template_file.user_data_bastion.rendered
  user_data_replace_on_change = false

  vpc_security_group_ids = [
    aws_security_group.sg.id
  ]
  subnet_id = aws_subnet.public_subnet_1.id

  tags = {
    "Patch Group" = "development"
    Environment = "development"
    Name = "Paula_test"
    
  }

  depends_on = [ aws_security_group.sg ]
  
}


