provider "aws" {
  region = var.region
}

# Data source to get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  # Canonical (official Ubuntu publisher)
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}


# Create the VPC
resource "aws_vpc" "production_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "Production VPC"
  }
}

#create internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.production_vpc.id

  tags = {
    Name = "Production IGW"
  }
}
#creating an elastic ip to associate with nat gateway
resource "aws_eip" "nat_eip" {
  depends_on = [aws_internet_gateway.igw]
}

#create nat gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet1.id

  tags = {
    Name = "NAT Gateway"
  }
}

#create the public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.production_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Public RT"
  }
}

#create the private route table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.production_vpc.id

  route {
    cidr_block     = var.all_cidr
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = {
    Name = "Private RT"
  }
}

#create public subnet 1
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.production_vpc.id
  cidr_block              = var.public_subnet1_cidr
  availability_zone       = var.avalailability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet 1"
  }
}

#create public subnet 2
resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.production_vpc.id
  cidr_block              = var.public_subnet2_cidr
  availability_zone       = var.avalailability_zone2
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet 2"
  }
}

#create the private subnet
resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.production_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "eu-north-1b"

  tags = {
    Name = "Private Subnet"
  }
}

#associate public route table with public subnet1
resource "aws_route_table_association" "public_association1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_rt.id
}

#associate public route table with public subnet2
resource "aws_route_table_association" "public_association2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_rt.id
}

#associate private route table with private subnet
resource "aws_route_table_association" "private_association1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_rt.id
}

#create jenkins security group
resource "aws_security_group" "jenkins_sg" {
  name        = "Jenkins SG"
  description = "Allow ports 8080 and 22"
  vpc_id      = aws_vpc.production_vpc.id

  ingress {
    description = "Jenkins"
    from_port   = var.jenkins_port
    to_port     = var.jenkins_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  ingress {
    description = "SSH"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }

  tags = {
    Name = "Jenkins SG"
  }
}

#create sonarqube security group
resource "aws_security_group" "sonarqube_sg" {
  name        = "SonarQube SG"
  description = "Allow ports 9000 and 22"
  vpc_id      = aws_vpc.production_vpc.id

  ingress {
    description = "SonarQube"
    from_port   = var.sonarqube_port
    to_port     = var.sonarqube_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  ingress {
    description = "SSH"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }

  tags = {
    Name = "SonarQube SG"
  }
}

#creating ansible security group
resource "aws_security_group" "ansible_sg" {
  name        = "Ansible SG"
  description = "Allow port 22"
  vpc_id      = aws_vpc.production_vpc.id


  ingress {
    description = "SSH"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }

  tags = {
    Name = "Ansible SG"
  }
}

#create grafana security group
resource "aws_security_group" "grafana_sg" {
  name        = "Grafana SG"
  description = "Allow ports 3000 and 22"
  vpc_id      = aws_vpc.production_vpc.id

  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  ingress {
    description = "SSH"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }

  tags = {
    Name = "Grafana SG"
  }
}

#create application security group
resource "aws_security_group" "app_sg" {
  name        = "Application SG"
  description = "Allow ports 80 and 22"
  vpc_id      = aws_vpc.production_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  ingress {
    description = "SSH"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }

  tags = {
    Name = "Application SG"
  }
}

#create load balancer security group
resource "aws_security_group" "lb_sg" {
  name        = "LoadBalancer SG"
  description = "Allow port 80"
  vpc_id      = aws_vpc.production_vpc.id
  ingress {
    description = "LoadBalancer"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }

  tags = {
    Name = "LoadBalancer SG"
  }
}

#create the acl
resource "aws_network_acl" "nacl" {
  vpc_id = aws_vpc.production_vpc.id
  subnet_ids = [
    aws_subnet.private_subnet1.id,
    aws_subnet.public_subnet2.id,
  aws_subnet.public_subnet1.id]


  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.all_cidr
    from_port  = 80
    to_port    = 80
  }


  ingress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = var.all_cidr
    from_port  = var.ssh_port
    to_port    = var.ssh_port
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 102
    action     = "allow"
    cidr_block = var.all_cidr
    from_port  = var.jenkins_port
    to_port    = var.jenkins_port
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 103
    action     = "allow"
    cidr_block = var.all_cidr
    from_port  = var.sonarqube_port
    to_port    = var.sonarqube_port
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 104
    action     = "allow"
    cidr_block = var.all_cidr
    from_port  = 3000
    to_port    = 3000
  }
  ingress {
  protocol   = "tcp"
  rule_no    = 200
  action     = "allow"
  cidr_block = var.all_cidr
  from_port  = 1024
  to_port    = 65535
}
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.all_cidr
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "Main ACL"
  }
}

#create the ECR repository
resource "aws_ecr_repository" "ecr_repo" {
  name = "docker-repository"

  image_scanning_configuration {
    scan_on_push = true
  }

}

resource "aws_key_pair" "auth_key" {
  key_name   = var.key_name
  public_key = var.key_value
}

# S3 backend bucket 'devops-projectterraform-state' is managed externally
# The bucket is created outside of this configuration (console/CLI).
# Do not manage it here to avoid backend initialization conflicts.
#configure s3 bucket
terraform {
  backend "s3" {
    bucket = "devops-projectterraform-state"
    key    = "prod/terraform.tfstate"
    region = "eu-north-1"
  }
}

#create a jenskins instance
resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.micro_instance
  availability_zone      = var.avalailability_zone
  subnet_id              = aws_subnet.public_subnet1.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = var.key_name
  user_data              = file("jenkins_install.sh")

  tags = {
    Name = "Jenkins"
  }
}

#sonarqube instance(used to test the quality of code, includes all code issues that need to be fixed before deploying the code)
#create a sonarqube instance

resource "aws_instance" "sonarqube" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.small_instance
  availability_zone      = var.avalailability_zone
  subnet_id              = aws_subnet.public_subnet1.id
  vpc_security_group_ids = [aws_security_group.sonarqube_sg.id]
  key_name               = var.key_name
  user_data              = file("sonarqube_install.sh")

  tags = {
    Name = "SonarQube-Ubuntu"
  }
}

#create the anible instance
resource "aws_instance" "ansible" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.micro_instance
  availability_zone      = var.avalailability_zone
  subnet_id              = aws_subnet.public_subnet1.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = var.key_name
  user_data              = file("ansible_install.sh")

  tags = {
    Name = "Ansible"
  }
}