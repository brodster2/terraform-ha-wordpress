variable "aws_profile" {
  description = "The aws profile to use in the ~/.aws/credentials file"
  default     = ""
}

variable "privateSubnetList" {
  description = "List of cidr blocks to assign to private subnets"
  type        = "list"
  default     = ["10.0.1.0/25", "10.0.1.128/25"]
}
