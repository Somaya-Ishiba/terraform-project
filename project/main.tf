data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Create a VPC
module "vpc-module" {
  source    = "./vpc-module"
  vpc_cidr  = "10.0.0.0/16"
}

#=====================================
#create subnet1  
module "public_subnet_1" {
  source = "./subnet-module"
  cidrsubnet = "10.0.0.0/24"
  pub-pri = true
  AZ = "us-east-1a"
  vpc_id = module.vpc-module.vpc_id 
  namesubnet = "public-subnet-1"
  
  }

#create subnet2  
module "public_subnet_2" {
  source = "./subnet-module"
  cidrsubnet = "10.0.2.0/24"
  pub-pri = true
  AZ = "us-east-1b"
  vpc_id = module.vpc-module.vpc_id 
  namesubnet = "public-subnet-2"
  
  }
#create subnet 3
module "private_subnet_1" {
  source      = "./subnet-module"
  cidrsubnet  = "10.0.1.0/24"
  AZ          = "us-east-1a"
  pub-pri     = false
  vpc_id      = module.vpc-module.vpc_id 
  namesubnet  = "private-subnet-1"
}
#create subnet 4
module "private_subnet_2" {
  source      = "./subnet-module"
  cidrsubnet  = "10.0.3.0/24"
  AZ          = "us-east-1b"
  pub-pri     = false
  vpc_id      = module.vpc-module.vpc_id 
  namesubnet  = "private-subnet-2"

}
#=============================

#create instance 1
resource "aws_instance" "proxy1" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = module.public_subnet_1.subnet_id
  vpc_security_group_ids = [
    aws_security_group.allow-ssh-http.id
  ]

  key_name               = "projectkey"
  associate_public_ip_address = true
  tags = {
    Name = "proxy1"
  }

  provisioner "remote-exec" {
  inline = [
    "sudo amazon-linux-extras enable nginx1",
    "sudo yum clean metadata",
    "sudo yum install -y nginx",
    <<-EOT
    sudo bash -c 'cat > /etc/nginx/nginx.conf <<EOF
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    server {
        listen 80;

        location / {
            proxy_pass http:// internal-int-alb-1920628433.us-east-1.elb.amazonaws.cominternal-int-alb-1920628433.us-east-1.elb.amazonaws.cominternal-int-alb-1920628433.us-east-1.elb.amazonaws.com
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
    }
}
EOF'
    EOT
    ,
    "sudo systemctl restart nginx",
    "sudo systemctl enable nginx"
  ]

 
}
    

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("/home/somaya/projectssh/projectkey.pem")
      host        = self.public_ip
    }
  }



#create instance 2
resource "aws_instance" "proxy2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = module.public_subnet_2.subnet_id
  vpc_security_group_ids = [
    aws_security_group.allow-ssh-http.id
  ]

  key_name               = "projectkey"
  associate_public_ip_address = true
  tags = {
    Name = "proxy2"
  }

 provisioner "remote-exec" {
  inline = [
    "sudo amazon-linux-extras enable nginx1",
    "sudo yum clean metadata",
    "sudo yum install -y nginx",
    <<-EOT
    sudo bash -c 'cat > /etc/nginx/nginx.conf <<EOF
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    server {
        listen 80;

        location / {
            proxy_pass http://internal-int-alb-1920628433.us-east-1.elb.amazonaws.com;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
    }
}
EOF'
    EOT
    ,
    "sudo systemctl restart nginx",
    "sudo systemctl enable nginx"
  ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("/home/somaya/projectssh/projectkey.pem")
    host        = self.public_ip
  }
}

}

#create instance 3
resource "aws_instance" "backend1" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = module.private_subnet_1.subnet_id
  vpc_security_group_ids = [
    aws_security_group.allow-ssh-http.id
  ]

  key_name               = "projectkey"
  associate_public_ip_address = false

  tags = {
    Name = "backend1"
  }
  
   provisioner "file" {
    source      = "index.html"
destination = "/home/ec2-user/index.html"
  
  connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("/home/somaya/projectssh/projectkey.pem")
      host        = self.private_ip
      bastion_host        = aws_instance.proxy1.public_ip
bastion_user        = "ec2-user"
bastion_private_key = file("/home/somaya/projectssh/projectkey.pem")

 
  }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y httpd",
      "sudo mv /home/ec2-user/index.html /var/www/html/index.html",
  "sudo systemctl start httpd",
  "sudo systemctl enable httpd"
  ]


    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("/home/somaya/projectssh/projectkey.pem")
      host        = self.private_ip
      bastion_host        = aws_instance.proxy1.public_ip
bastion_user        = "ec2-user"
bastion_private_key = file("/home/somaya/projectssh/projectkey.pem")
       
    }
  }
}


#create instance 4
resource "aws_instance" "backend2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = module.private_subnet_2.subnet_id
  vpc_security_group_ids = [aws_security_group.allow-ssh-http.id]
  key_name               = "projectkey"
  associate_public_ip_address = false

  tags = {
    Name = "backend2"
  }
#using lfile provisioner to copy files to private remote machines
   provisioner "file" {
    source      = "ind.html"
destination = "/home/ec2-user/index.html"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("/home/somaya/projectssh/projectkey.pem")
      host        = self.private_ip
      bastion_host        = aws_instance.proxy2.public_ip
bastion_user        = "ec2-user"
bastion_private_key = file("/home/somaya/projectssh/projectkey.pem")
    }
    }
  
  
#using remoexec file privisioner to run commands
  provisioner "remote-exec" {
    inline = [
        "sudo yum install -y httpd",
  "sudo mv /home/ec2-user/index.html /var/www/html/index.html",
  "sudo systemctl start httpd",
  "sudo systemctl enable httpd"
  ]


    
connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("/home/somaya/projectssh/projectkey.pem")
      host        = self.private_ip
      bastion_host        = aws_instance.proxy2.public_ip
bastion_user        = "ec2-user"
bastion_private_key = file("/home/somaya/projectssh/projectkey.pem")
    }
    
  }
}

#security group
resource "aws_security_group" "allow-ssh-http" {
  name        = "allow-ssh-http"
  description = "Allow ssh and http inbound traffic and all outbound traffic"
  vpc_id      = module.vpc-module.vpc_id

  tags = {
    Name = "allow_ssh_http"
  }
}
#ssh
resource "aws_vpc_security_group_ingress_rule" "allow-ssh" {
  security_group_id = aws_security_group.allow-ssh-http.id 
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

#http
resource "aws_vpc_security_group_ingress_rule" "allow-http" {
  security_group_id = aws_security_group.allow-ssh-http.id 
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_egress_rule" "allowallipv4" {
security_group_id = aws_security_group.allow-ssh-http.id 
cidr_ipv4 = "0.0.0.0/0"
ip_protocol = "-1"

}

#==================
#network
module "networking" {
  source              = "./network-module"
  vpc_id              = module.vpc-module.vpc_id
  public_subnet_id    = module.public_subnet_1.subnet_id
  public_subnet_2_id   = module.public_subnet_2.subnet_id
  private_subnet_1_id = module.private_subnet_1.subnet_id
  private_subnet_2_id = module.private_subnet_2.subnet_id
}
#=======================================
#ALB
resource "aws_lb" "public_alb" {
  name               = "public-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [module.public_subnet_1.subnet_id, module.public_subnet_2.subnet_id]
  security_groups    = [aws_security_group.allow-ssh-http.id]

  tags = {
    Name = "PublicALB"
  }
}

resource "aws_lb_target_group" "proxy_tg" {
  name     = "proxy-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc-module.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "proxy1" {
  target_group_arn = aws_lb_target_group.proxy_tg.arn
  target_id        = aws_instance.proxy1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "proxy2" {
  target_group_arn = aws_lb_target_group.proxy_tg.arn
  target_id        = aws_instance.proxy2.id
  port             = 80
}

resource "aws_lb_listener" "public_http" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.proxy_tg.arn
  }
}
#=============================================
#load balancer
resource "aws_lb" "internal_alb" {
  name               = "int-alb"
  internal           = true
  load_balancer_type = "application"
  subnets            = [module.private_subnet_1.subnet_id, module.private_subnet_2.subnet_id]
  security_groups    = [aws_security_group.allow-ssh-http.id]

  tags = {
    Name = "InternalALB"
  }
}

resource "aws_lb_target_group" "backend_tg" {
  name     = "backend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc-module.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "backend1" {
  target_group_arn = aws_lb_target_group.backend_tg.arn
  target_id        = aws_instance.backend1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "backend2" {
  target_group_arn = aws_lb_target_group.backend_tg.arn
  target_id        = aws_instance.backend2.id
  port             = 80
}

resource "aws_lb_listener" "internal_http" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}
