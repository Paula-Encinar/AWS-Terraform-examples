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

resource "null_resource" "install_lambda_python" {
  provisioner "local-exec" {
    working_dir = "${path.module}/../lambda/ec2-reboot"
    command = <<-EOF
      # Create a temporary directory for packaging
      mkdir temp_site_packages

      # Download the Python packages listed in requirements.txt into the temporary directory
      pip install -r requirements.txt -t temp_site_packages

      # Copy the Lambda function code to the temporary directory
      cp lambda_function.py temp_site_packages

    EOF
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

data "archive_file" "zip_the_python_code" {
type        = "zip"
depends_on = [ null_resource.install_lambda_python ]
source_dir  = "${path.module}/../lambda/ec2-reboot/temp_site_packages"
output_path = "${path.module}/../lambda/ec2-reboot/lambda_deployment_package.zip"
}

resource "aws_s3_object" "lambda_bucket_object" {
  bucket = "paula-lambda"

  depends_on = [data.archive_file.zip_the_python_code]

  key    = "testing-${data.archive_file.zip_the_python_code.output_base64sha256}.zip"
  source = data.archive_file.zip_the_python_code.output_path
}

resource "aws_lambda_function" "terraform_lambda_func" {
source_code_hash = data.archive_file.zip_the_python_code.output_base64sha256
s3_bucket = "paula-lambda"
s3_key = aws_s3_object.lambda_bucket_object.key
function_name                  = "Spacelift_Test_Lambda_Function"
role                           = aws_iam_role.lambda_role.arn
handler                        = "lambda_function.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}



