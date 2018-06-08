variable "aws_profile" {
  description = "The aws profile to use in the ~/.aws/credentials file"
  default     = ""
}

variable "private_subnet_cidr_list" {
  description = "List of cidr blocks to assign to private subnets"
  type        = "list"
  default     = ["10.0.1.0/25", "10.0.1.128/25"]
}

variable "private_subnet_az_list" {
  description = "List of availability zones to place private subnets"
  default     = ["eu-west-1b", "eu-west-1c"]
}

variable "rds_root_password" {
  description = "Password for the root account when creating the RDS DB instance"
  type        = "string"
}

variable "trusted_ssh_cidrs" {
  description = "List of cidr blocks which the bastion host can be accessed from. Used by aws_security_group.bastionSsh"
  type        = "list"
}

variable "bastion_host_key" {
  description = "Keypair to use to login to the bastion host"
  type        = "string"
}
