resource "aws_subnet" "subnetcreate" {
  vpc_id            = var.vpc_id
  cidr_block        = var.cidrsubnet
  availability_zone = var.AZ 
  map_public_ip_on_launch = var.pub-pri

  tags = {
    Name = var.namesubnet
  }
}
