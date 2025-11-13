variable "instance_profile" {
  description = "Existing IAM instance profile (e.g., LabInstanceProfile)"
  type        = string
}

variable "db_user" {
  description = "Database username for RDS MySQL"
  type        = string
  default     = "admin"
}

variable "db_pass" {
  description = "Database password for RDS MySQL"
  type        = string
  default     = "Admin123!"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "petshop"
}
