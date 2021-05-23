#configure the provider & required plugings
terraform {  
    required_providers {
      aws = {
          source = "hashicorp/aws"
          version = "~>3.0"
      }
    }
}

#configure aws providor
provider "aws" {
  region = "ap-south-1"
}

#create VPC
resource "aws_vpc" "lab-vpc" {
    cidr_block = var.cidr_block[0]
    tags = {
        Name = "lab-vpc"
    }  
}

#create public subnet
resource "aws_subnet" "lab-subnet1" {
  vpc_id = aws_vpc.lab-vpc.id
  cidr_block = var.cidr_block[1]
  tags = {
    "Name" = "lab-subnet1"
  }
}

#configure the IGW
resource "aws_internet_gateway" "lab-igw" {
  vpc_id = aws_vpc.lab-vpc.id
  tags = {
    "Name" = "lab-igw"
  }
}

resource "aws_security_group" "lab-sg" {
  name = "Lab Security Group"
  description = "To allow inbound and outbound traffic to mylab"
  vpc_id = aws_vpc.lab-vpc.id

  dynamic ingress {
      iterator = port
      for_each = var.ports
      content {
          from_port = port.value
          to_port = port.value
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
      }
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  } 

  tags = {
    "Name" = "lab-sg"
  }
}

resource "aws_route_table" "lab-rt" {
    vpc_id = aws_vpc.lab-vpc.id
    
    route  {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.lab-igw.id
    }
 
    tags = {
       "Name" = "lab-rt"
    } 
}

resource "aws_route_table_association" "lab-rt-assoc" {
    subnet_id = aws_subnet.lab-subnet1.id
    route_table_id = aws_route_table.lab-rt.id
 }

 resource "aws_instance" "jenkins-server" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "ec2"
  vpc_security_group_ids = [aws_security_group.lab-sg.id]
  subnet_id = aws_subnet.lab-subnet1.id
  associate_public_ip_address = true
  user_data = file("./InstallJenkins.sh")

  tags = {
    Name = "jenkins-server"
  }
}

 resource "aws_instance" "ansible-controller" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "ec2"
  vpc_security_group_ids = [aws_security_group.lab-sg.id]
  subnet_id = aws_subnet.lab-subnet1.id
  associate_public_ip_address = true
  user_data = file("./InstallAnsible.sh")

  tags = {
    Name = "ansible-controller"
  }
}

#ansible managed node-01 - tomcat
 resource "aws_instance" "ansible-managed-node-tomcat" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "ec2"
  vpc_security_group_ids = [aws_security_group.lab-sg.id]
  subnet_id = aws_subnet.lab-subnet1.id
  associate_public_ip_address = true
  user_data = file("./Addansibleuser.sh")

  tags = {
    Name = "ansible-managed-node-tomcat"
  }
}

#ansible managed node-02 - docker
 resource "aws_instance" "ansible-managed-node-docker" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "ec2"
  vpc_security_group_ids = [aws_security_group.lab-sg.id]
  subnet_id = aws_subnet.lab-subnet1.id
  associate_public_ip_address = true
  user_data = file("./Docker.sh")

  tags = {
    Name = "ansible-managed-node-docker"
  }
}

#Nexus
 resource "aws_instance" "nexus" {
  ami           = var.ami
  instance_type = var.instance_type_nexus
  key_name = "ec2"
  vpc_security_group_ids = [aws_security_group.lab-sg.id]
  subnet_id = aws_subnet.lab-subnet1.id
  associate_public_ip_address = true
  user_data = file("./Nexus.sh")

  tags = {
    Name = "nexus"
  }
}