# module "s3" {
#   source = "./s3"
#   bucket = "ssmpaulatest"
# }

# module "s3_test" {
#   source = "./s3"
#   bucket = "normalpaulatest"
  
# }


# resource "aws_s3_bucket_policy" "bucket_policy_ssm_ec2_logs" {
#   bucket = module.s3.bucket_name
#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": "*",
#       "Action": [ "s3:*" ],
#       "Resource": [
#         "arn:aws:s3:::${module.s3.bucket_name}",
#         "arn:aws:s3:::${module.s3.bucket_name}/*"
#       ]
#     }
#   ]
# }
# EOF
# }