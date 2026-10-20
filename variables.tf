variable "aws_region" {
  description = "Target AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "app_vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "db_vpc_cidr" {
  default = "10.2.0.0/16"
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
  default     = "SecurePasswd2026!"
}
