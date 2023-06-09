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


data "aws_ami" "amazon-windows" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2012-R2_RTM-English-64Bit-Base-*"]
  }
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.amazon-windows.id
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.dev-resources-iam-profile.name

  vpc_security_group_ids = [
    var.bastion_security_group_id
  ]
  subnet_id = var.ec2_subnet_id_1

  tags = {
    "Patch Group" = "development"
    Environment = "development"
    Name = "Paula_test"
    
  }

  depends_on = [ var.bastion_security_group_id ]
  
}
