variable "cidrsubnet" {
  description = "The CIDR block for the subnet"
  type        = string
}
variable "namesubnet" {
  description = "The name of the subnet"
  type        = string
  default     = "my-subnet"
}
variable "vpc_id" {
type = string


}
variable "pub-pri" {
type        = bool
description = "The public or private choice of the subnet"

}
variable "AZ" {
type        = string
description = "The availability zone of the subnet"
}
