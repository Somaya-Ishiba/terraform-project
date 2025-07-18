variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_id" {
  description = "The ID of the first public subnet"
  type        = string
}

variable "public_subnet_2_id" {
  description = "The ID of the second public subnet (optional, for second AZ)"
  type        = string
  default     = null
}

variable "private_subnet_1_id" {
  description = "The ID of the first private subnet"
  type        = string
}

variable "private_subnet_2_id" {
  description = "The ID of the second private subnet"
  type        = string
}
