terraform {
  backend "remote" {
    organization = "hala-AWS"

    workspaces {
      name = "hala-AWS"
    }
  }
}
provider "aws" {
    region = "us-east-2"
    access_key = "****************"
    secret_key = "*****************"
}
# 1. create VPC
resource "aws_vpc" "myvpc1" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
       Name = "myvpc1"
    }
}
# 2. create subnet
resource "aws_subnet" "mySubnet1" {
    vpc_id = aws_vpc.myvpc1.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-2a"
    map_public_ip_on_launch = true
    tags = {
        Name = "mySubnet1"
    }
}
# 3. creat Network interface
resource "aws_network_interface" "mywebnic" {
    subnet_id = aws_subnet.mySubnet1.id
    private_ips = ["10.0.0.10"]
    security_groups = [aws_security_group.devopssg.id]
}
resource "aws_network_interface" "mywebnic1" {
    subnet_id = aws_subnet.mySubnet1.id
    private_ips = ["10.0.0.239"]
    security_groups = [aws_security_group.devopssg.id]
}
# 4. security group to allw port 22 and port 80
resource "aws_security_group" "devopssg"{
    name = "Devops_Demo_SG"
    description = "Allow inbound traffic"
    vpc_id      = aws_vpc.myvpc1.id
     ingress {
         description = "Allowing access to our web server"
         from_port = 80
         to_port = 80
         protocol = "tcp"
         cidr_blocks = ["0.0.0.0/0"] # making it accssible to the internet
    }
     ingress {
         description = "Allowing access to our web server"
         from_port = 22
         to_port = 22
         protocol = "tcp"
         cidr_blocks  = ["0.0.0.0/0"] # making it accssible to the internet
    }
     egress{
         from_port = 0
         to_port = 0
         protocol = "-1"
         cidr_blocks = ["0.0.0.0/0"]
         ipv6_cidr_blocks  =["::/0"]
    }
     tags = {
         Name = "allow_access"
     }    
}
# 5. create Amazon two ES2 server
resource "aws_instance" "Dev" {
    ami = "ami-0233c2d874b811deb"
    instance_type = "t2.micro"
    network_interface {
    network_interface_id = aws_network_interface.mywebnic1.id
    device_index = 0
    }    
    tags = {
        Name = "Dev"
    }
}
resource "aws_instance" "Prod" {
    ami = "ami-0233c2d874b811deb"
    instance_type = "t2.micro"
    network_interface {
    network_interface_id = aws_network_interface.mywebnic.id
    device_index = 0
    }
    tags = {
        Name = "Prod"
    }
}
