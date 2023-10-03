###################################################
# S3 Bucket tfstate packer network
####################################################

resource "aws_s3_bucket" "log_manifest" {
  bucket = var.bucket
  force_destroy = true

  tags = {
    Name        = "log-manifest"
    Environment = "Development"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.log_manifest.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

####################################################
# S3 Bucket ACL Packer Network
####################################################

resource "aws_s3_bucket_acl" "packer_manifest" {
  bucket = aws_s3_bucket.log_manifest.id
  acl    = "private"
}

###################################################
# Define Bucket Encryption
###################################################

resource "aws_s3_bucket_server_side_encryption_configuration" "log_manifest" {
  bucket = aws_s3_bucket.log_manifest.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

####################################################
# Enable S3 Bucket Versioning
####################################################

resource "aws_s3_bucket_versioning" "log-manifest" {
  bucket = aws_s3_bucket.log_manifest.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "bucket_deny_http_policy" {
  bucket = aws_s3_bucket.log_manifest.bucket
  count = aws_s3_bucket.log_manifest.bucket == "ssmpaulatest" ? 0 : 1

  policy = jsonencode(
{
    Version: "2012-10-17",
    Statement: [
        {
            Sid: "DenyHTTPConnection",
            Effect: "Deny",
            Principal: "*",
            Action: "s3:*",
            Resource: [
                "arn:aws:s3:::${aws_s3_bucket.log_manifest.bucket}",
                "arn:aws:s3:::${aws_s3_bucket.log_manifest.bucket}/*"
            ],
            Condition: {
                Bool: {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
  })
}




resource "aws_s3_bucket_policy" "bucket_ssm_http_policy" {
  bucket = aws_s3_bucket.log_manifest.bucket
  count = aws_s3_bucket.log_manifest.bucket == "ssmpaulatest" ? 1 : 0

  policy = jsonencode(
{
    Version: "2012-10-17",
    Statement: [
        {
            Sid: "DenyHTTPConnection",
            Effect: "Deny",
            Principal: "*",
            Action: "s3:*",
            Resource: [
                "arn:aws:s3:::${aws_s3_bucket.log_manifest.bucket}",
                "arn:aws:s3:::${aws_s3_bucket.log_manifest.bucket}/*"
            ],
            Condition: {
                Bool: {
                    "aws:SecureTransport": "false"
                }
            }
        },
        {
            Sid: "ReadandWrite",
            Effect: "Allow",
            Principal: "*",
            Action: [ "s3:*" ],
            Resource: [
              "arn:aws:s3:::${aws_s3_bucket.log_manifest.bucket}",
              "arn:aws:s3:::${aws_s3_bucket.log_manifest.bucket}/*"
        ]
        }

    ]
  })
}



# resource "aws_s3_bucket_policy" "bucket_policy" {
#   bucket = aws_s3_bucket.log_manifest.id

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": "*",
#       "Action": [ "s3:*" ],
#       "Resource": [
#         "arn:aws:s3:::log-manifest",
#         "arn:aws:s3:::log-manifest/*"
#       ]
#     }
#   ]
# }
# EOF
# }
