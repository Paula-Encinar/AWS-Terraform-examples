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

resource "aws_instance" "app_server" {
  ami           = "ami-030770b178fa9d374"
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.dev-resources-iam-profile.name

  vpc_security_group_ids = [
    aws_security_group.sg.id
  ]
  subnet_id = aws_subnet.private_subnet_1.id
  root_block_device {
  delete_on_termination = var.long_environment == "production" ? false : true
  volume_size           = 8
  volume_type           = "gp2"
  tags = {
    "Name" = "MSExports-rootvolume-${var.long_environment}"
  }
}

  tags = {
    "Patch Group" = "development"
    Environment = "development"
    Name = "Paula_test_development"
    
  }

  depends_on = [ aws_security_group.sg ]
  
}

data "aws_instance" "ec2_my_admin_instance" {
  depends_on = [
    aws_instance.app_server
  ]
  filter {
    name = "tag:Name"
    values = ["Paula_test_development"]
  }
}

data "aws_ebs_volume" "ebs_volume" {
  depends_on = [
    aws_instance.app_server
  ]  
  most_recent = true

  filter {
    name   = "volume-type"
    values = ["gp2"]
  }
  filter {
    name   = "tag:Name"
    values = ["MSExports-rootvolume-${var.long_environment}"]
  }
}

output "id_instance" {
  value = "${data.aws_instance.ec2_my_admin_instance.id}"
}

# output "volumne_id_instance" {
#   value = "${lookup(data.aws_instance.ec2_my_admin_instance.ebs_block_device[0], "volume_id")}"
# }

output "volumne_id_instance" {
  value = "${data.aws_ebs_volume.ebs_volume.id}"
}