#trivy:ignore:AWS-0178 VPC Flow Logs. TODO: Check if free/very cheap and implement if so
module "factorio_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.14.0"

  name = "factorio-vpc"
  cidr = "10.1.0.0/27"

  azs            = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets = ["10.1.0.0/28"]

  enable_nat_gateway = false
  enable_vpn_gateway = false
}

resource "aws_security_group" "factorio_vpc" {
  name        = "factorio-sg"
  description = "Control traffic to Factorio server"
  vpc_id      = module.factorio_vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  count = var.ssh_key_pair_name != null ? 1 : 0

  description       = "Allow SSH traffic from my IPv4 address"
  security_group_id = aws_security_group.factorio_vpc.id
  cidr_ipv4         = local.my_ipv4
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_udp_factorio_server_ipv4" {
  description       = "Allow UDP traffic to Factorio server from my IPv4 address"
  security_group_id = aws_security_group.factorio_vpc.id
  cidr_ipv4         = local.my_ipv4
  from_port         = local.factorio_port
  ip_protocol       = "udp"
  to_port           = local.factorio_port
}

#trivy:ignore:AWS-0104 Egress to internet TODO: Check if needed
resource "aws_vpc_security_group_egress_rule" "allow_all_egress" {
  description       = "Allow all outbound traffic"
  security_group_id = aws_security_group.factorio_vpc.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_iam_role" "factorio_server" {
  name               = "factorio_server"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
}
resource "aws_iam_instance_profile" "factorio_server" {
  name = "factorio_server"
  role = aws_iam_role.factorio_server.name
}

resource "aws_iam_role_policy" "get_factorio_assets" {
  name = "get_factorio_assets"
  role = aws_iam_role.factorio_server.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::john-factorio-assets/*"
        ]
      },
    ]
  })
}

// TODO Scope down this policy to just required perms to SSM to instance
resource "aws_iam_role_policy_attachment" "aws_ssm_managed_instance_core" {
  role       = aws_iam_role.factorio_server.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "aws_cloudwatch_agent_server_role" {
  role       = aws_iam_role.factorio_server.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

data "aws_ami" "aws_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["amazon"]
}

#trivy:ignore:AWS-0028 Instance metadata service token TODO: Implement this
#trivy:ignore:AWS-0131 Unecrypted block device. TODO: Check cost and implement if free/very cheap
resource "aws_instance" "factorio_server" {

  ami           = data.aws_ami.aws_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids      = [aws_security_group.factorio_vpc.id]
  subnet_id                   = module.factorio_vpc.public_subnets[0]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.factorio_server.name

  key_name = var.ssh_key_pair_name

  user_data                   = file("${path.module}/scripts/factorio_server_setup.sh")
  user_data_replace_on_change = true

  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = var.spot_price
    }
  }
}
