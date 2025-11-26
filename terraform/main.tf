terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
    profile = "aws_david_dev"
    region  = var.aws_region
}

provider "external" {}

data "external" "enable_brotli" {
  program = ["bash", "../bin/enable_brotli.sh"]

  query = {
    zone_id  = var.cloudflare_zone_id
    api_token = var.cloudflare_token
  }
}
  


####################
#### aws configs 

resource "aws_instance" "staging" {
  count         = var.staging_instance_count
  ami           = var.ami_id #"ami-09e67e426f25ce0d7"  # Amazon Linux 2023 (Free Tier)
  instance_type = var.instance_type
  key_name      = var.aws_key_name
  security_groups = [aws_security_group.staging_sg.name]
  associate_public_ip_address = true

  root_block_device {
    volume_size = var.ebs_volume_size  # 10GB Free Tier
  }

  user_data = file("../bin/user_data.sh")  # Bootstrap script

  tags = {
    Name = "Giggl-Staging"
  }
}

resource "aws_security_group" "staging_sg" {
  name        = "staging-sg"
  description = "Allow HTTP, HTTPS, and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
 