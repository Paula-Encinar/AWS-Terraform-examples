resource "aws_iam_role" "lambda_role" {
  name = "ec2_reboot_lambda_function_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
}


resource "aws_iam_policy" "iam_policy_for_lambda" {

  name        = "laws_iam_policy_for_terraform_aws_lambda_role"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
        Effect   = "Allow"
      },
    ]
  })
}

resource "aws_iam_policy" "iam_policy_for_lambda_ec2_reboot" {
  name        = "aws_iam_policy_for_terraform_aws_lambda_ec2_reboot_role"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : "ec2:RebootInstances",
        Resource : "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role_ec2_reboot" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda_ec2_reboot.arn
}

data "archive_file" "zip_the_python_code" {
type        = "zip"
source_dir  = "../lambda/ec2-reboot"
output_path = "../lambda/hello-python.zip"
}

resource "aws_lambda_function" "terraform_lambda_func" {
filename                       = "../lambda/hello-python.zip"
function_name                  = "Spacelift_Test_Lambda_Function"
role                           = aws_iam_role.lambda_role.arn
handler                        = "lambda_function.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
environment {
  variables = {
    EC2_INSTANCE_ID = aws_instance.app_server.id
    EC2_INSTANCE_ID_POWERBI = var.long_environment == "production" ? length(aws_instance.powerbi_server_automation[*].id) > 0 ? aws_instance.powerbi_server_automation[0].id : "" : ""

    }
  }
}

resource "aws_lambda_permission" "remove_inactive_auditors_with_audits_lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.terraform_lambda_func.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule_rule.arn
}

