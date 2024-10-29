locals {
  region        = "eu-west-1"
  factorio_port = "34197"
  // TODO make this a data lookup
  factorio_ami_id = "ami-07d49117b6f95f5c2a" // red_hat_9_eu_west_1_ami
  my_ipv4         = "${chomp(data.http.my_ipv4.response_body)}/32"
}

provider "aws" {
  region = "eu-west-1"
}

data "http" "my_ipv4" {
  url = "https://ipv4.icanhazip.com"
}

module "factorio_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "factorio-vpc"
  cidr = "10.1.0.0/27"

  azs            = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  public_subnets = ["10.1.0.0/28"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_security_group" "factorio_vpc" {
  name        = "factorio-sg"
  description = "Control traffic to Factorio server"
  vpc_id      = module.factorio_vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.factorio_vpc.id
  cidr_ipv4         = local.my_ipv4
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_udp_factorio_server_ipv4" {
  security_group_id = aws_security_group.factorio_vpc.id
  cidr_ipv4         = local.my_ipv4
  from_port         = local.factorio_port
  ip_protocol       = "udp"
  to_port           = local.factorio_port
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress" {
  security_group_id = aws_security_group.factorio_vpc.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_instance" "factorio_server" {
  ami           = local.factorio_ami_id
  instance_type = "t3.medium"

  vpc_security_group_ids      = [aws_security_group.factorio_vpc.id]
  subnet_id                   = module.factorio_vpc.public_subnets[0]
  associate_public_ip_address = true

  key_name = var.ssh_key_pair_name

  tags = {
    Name = "factorio-server"
  }
}
