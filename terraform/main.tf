terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "main"
  cidr = "10.0.0.0/16"

  azs            = ["${var.aws_region}a"]
  public_subnets = ["10.0.1.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

# Security Group Module
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "terraform-server-sg"
  description = "Security group for EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22          # Allows incoming traffic on port 22
      to_port     = 22          # Same as from_port, meaning only port 22 is allowed
      protocol    = "tcp"       # Uses TCP protocol (common for SSH)
      description = "SSH"       # A human-readable label indicating this rule is for SSH access
      cidr_blocks = "0.0.0.0/0" # Allows incoming SSH from any IP address (0.0.0.0/0 means anywhere)
    },
    {
      from_port   = 80          # Allows incoming traffic on port 80
      to_port     = 80          # Same as from_port, meaning only port 80 is allowed
      protocol    = "tcp"       # Uses TCP protocol (common for HTTP)
      description = "HTTP"      # A human-readable label indicating this rule is for HTTP access
      cidr_blocks = "0.0.0.0/0" # Allows incoming HTTP from any IP address (0.0.0.0/0 means anywhere)
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

# EC2 Instance Module
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  name = "terraform-server"

  instance_type          = var.instance_type
  ami                    = "ami-03f65b8614a860c29"  # Ubuntu 22.04 LTS in us-west-2
  monitoring             = true
  vpc_security_group_ids = [module.security_group.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}
