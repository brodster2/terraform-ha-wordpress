variable "aws_profile" {
  description = "The aws profile to use in the ~/.aws/credentials file"
  default     = ""
}

variable "private_subnet_cidr_list" {
  description = "List of cidr blocks to assign to private subnets"
  type        = "list"
  default     = ["10.0.1.0/25", "10.0.1.128/25"]
}

variable "mysql_root_password" {
  description = "Password for the root account when creating the RDS DB instance"
  type        = "string"
}

variable "mysql_user_password" {
  description = "Password for the user account for WordPress with limited permissions"
  type        = "string"
}

variable "load_balancer_name" {
  type    = "string"
  default = "wordpress-alb"
}
