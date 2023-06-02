variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "AppNodeServerInstance"
}

variable "region" {
    description = "Default region"
    default = "us-west-2"
}
variable "packer_ami_id" {
  description = "Packer Builded AMI"
  type        = string
}

