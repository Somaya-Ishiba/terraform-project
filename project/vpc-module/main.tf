resource "aws_vpc" "projectvpc" {
   cidr_block = var.vpc_cidr

  
  tags = {
    Name = "Main-project-VPC"
  }
}
