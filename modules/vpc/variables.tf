variable "cidr_block" {
  type    = list(string)
  default = ["10.0.0.0/16", "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
}

variable "nat_gateway_subnet_index" {
  description = "Index of the subnet to use for the NAT Gateway (0 or 1)"
  type        = number
  default     = 0
}