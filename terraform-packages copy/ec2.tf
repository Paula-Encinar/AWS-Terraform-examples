# Patch Baselines
resource "aws_ssm_patch_baseline" "baseline" {
  name             = "Paula-test-baseline"
  description      = "Paula baseline"
  operating_system = "AMAZON_LINUX_2"

  approved_patches                  = var.approved_patches
  rejected_patches                  = var.rejected_patches
  approved_patches_compliance_level = var.approved_patches_compliance_level

  dynamic "approval_rule" {
    for_each = toset(var.patch_baseline_approval_rules)
    content {

      approve_after_days  = approval_rule.value.approve_after_days
      compliance_level    = approval_rule.value.compliance_level
      enable_non_security = approval_rule.value.enable_non_security


      dynamic "patch_filter" {
        for_each = approval_rule.value.patch_baseline_filters

        content {
          key    = patch_filter.value.name
          values = patch_filter.value.values
        }
      }
    }
  }
  tags = var.tags
}


resource "aws_ssm_patch_group" "patchgroup" {
  baseline_id = aws_ssm_patch_baseline.baseline.id
  patch_group = "development"
}


resource "aws_ssm_maintenance_window" "scan" {
  name              = "scan-${var.name}"
  cutoff            = var.scan_cutoff
  description       = "Maintenance window for scanning for patch compliance"
  duration          = var.scan_duration
  schedule          = "cron(33 12 * * ? *)"
  schedule_timezone = var.schedule_timezone
  tags              = var.tags
}

resource "aws_ssm_maintenance_window" "install" {
  name              = "install-${var.name}"
  cutoff            = var.install_cutoff
  description       = "Maintenance window for applying patches"
  duration          = var.install_duration
  schedule          = "cron(36 12 * * ? *)"
  schedule_timezone = var.schedule_timezone
  tags              = var.tags
}

resource "aws_ssm_maintenance_window_target" "scan" {
  window_id     = aws_ssm_maintenance_window.scan.id
  resource_type = "INSTANCE"

  targets {
    key    = "tag:Patch Group"
    values = ["development"]
  }
}

resource "aws_ssm_maintenance_window_task" "scan" {
  max_concurrency  = var.max_scan_concurrency
  max_errors       = var.max_scan_errors
  priority         = 1
  service_role_arn = var.service_role_arn
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-RunPatchBaseline"
  window_id        = aws_ssm_maintenance_window.scan.id

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.scan.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      comment              = "Runs a compliance scan"
      # service_role_arn     = var.scan_notification_role_arn
      timeout_seconds      = 120

      parameter {
        name   = "Operation"
        values = ["Scan_development"]
      }
    }
  }
}

resource "aws_ssm_maintenance_window_target" "install" {
  # for_each      = var.platforms
  window_id     = aws_ssm_maintenance_window.install.id
  resource_type = "INSTANCE"

  targets {
    key    = "tag:Patch Group"
    values = ["development"]
  }
}

resource "aws_ssm_maintenance_window_task" "install" {
  max_concurrency  = var.max_install_concurrency
  max_errors       = var.max_install_errors
  priority         = 1
  service_role_arn = var.service_role_arn
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-RunPatchBaseline"
  window_id        = aws_ssm_maintenance_window.install.id

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.install.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      comment              = "Installs necessary patches"
      # service_role_arn     = var.install_notification_role_arn
      timeout_seconds      = 120

      parameter {
        name   = "Operation"
        values = ["Install_development"]
      }
    }
  }
}

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


data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20230119.1-x86_64-gp2"]
  }
}

data "template_file" "user_data"{
  template = file("${path.module}/template/MSExports_user_data.sh")
}



resource "aws_instance" "app_server" {
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.micro"
  # key_name = "test"
  iam_instance_profile = aws_iam_instance_profile.dev-resources-iam-profile.name 
  user_data                   = data.template_file.user_data.rendered
  user_data_replace_on_change = false

  vpc_security_group_ids = [
    aws_security_group.sg.id
  ]

  tags = {
    "Patch Group" = var.long_environment
    Environment = var.long_environment
    Name = "Paula_test"
    
  }

  depends_on = [ aws_security_group.sg ]
  
}


resource "aws_instance" "powerbi_server_automation" {
  count                       = var.long_environment == "production" ? 1 : 0
  ami                         = "ami-0fe0759579a2836cc"
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.dev-resources-iam-profile.name 
  # user_data                   = data.template_file.user_data_bastion.rendered
  # user_data_replace_on_change = false

  vpc_security_group_ids = [
    aws_security_group.sg.id
  ]

  tags = {
    "Patch Group" = var.long_environment
    Environment   = var.long_environment
    "Name"        = "powerbi_server-automation-${var.long_environment}"

  }

}

#ids
data "aws_instance" "powerbi_ec2_id" {
  count = var.long_environment == "production" ? 1 : 0
  depends_on = [
    aws_instance.powerbi_server_automation
  ]

  filter {
    name   = "tag:Name"
    values = [aws_instance.powerbi_server_automation[0].tags.Name]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}
