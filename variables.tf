variable "aws_region" {
  description = "AWS region to deploy in"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID to use (Amazon Linux 2 recommended). If empty, provider will lookup latest Amazon Linux 2 AMI"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "Optional key pair name for SSH (if you want). Leave empty to not set."
  type        = string
  default     = ""
}

variable "instance_profile" {
  description = "Existing instance profile to attach (e.g. LabInstanceProfile in AWS Academy). Leave empty to not attach."
  type        = string
  default     = ""
}

variable "allow_ssh_from" {
  description = "IP range allowed for SSH (if key provided). Use '' to disable or 0.0.0.0/0 to allow (not recommended)"
  type        = string
  default     = ""
}
