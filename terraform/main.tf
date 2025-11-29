terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}



########################################
# 1️⃣ VPC + Subnets
########################################
resource "aws_vpc" "davids_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "davids-vpc" }
}

resource "aws_subnet" "davids_subnet_a" {
  vpc_id                  = aws_vpc.davids_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = { Name = "davids-subnet-a" }
}

resource "aws_subnet" "davids_subnet_b" {
  vpc_id                  = aws_vpc.davids_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = { Name = "davids-subnet-b" }
}

resource "aws_security_group" "davids_sg" {
  name        = "davids-sg"
  description = "Allow SageMaker Studio access"
  vpc_id      = aws_vpc.davids_vpc.id

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

########################################
# 2️⃣ IAM Role
########################################
resource "aws_iam_role" "sagemaker_execution_role" {
  name = "sagemaker-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = { Service = "sagemaker.amazonaws.com" },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sagemaker_full_access" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

########################################
# 3️⃣ SageMaker Domain
########################################
resource "aws_sagemaker_domain" "davids_domain" {
  domain_name = "davids_domain"
  auth_mode   = "IAM"
  vpc_id      = aws_vpc.davids_vpc.id
  subnet_ids  = [
    aws_subnet.davids_subnet_a.id,
    aws_subnet.davids_subnet_b.id
  ]
  app_network_access_type = "PublicInternetOnly"

  default_user_settings {
    execution_role = aws_iam_role.sagemaker_execution_role.arn
    security_groups = [aws_security_group.davids_sg.id]
    jupyter_server_app_settings {
      default_resource_spec {
        instance_type = "ml.t2.medium"
      }
    }
  }
}

########################################
# 4️⃣ SageMaker User Profile
########################################
resource "aws_sagemaker_user_profile" "user_dave" {
  domain_id         = aws_sagemaker_domain.davids_domain.id
  user_profile_name = "dave"

  user_settings {
    execution_role  = aws_iam_role.sagemaker_execution_role.arn
    security_groups = [aws_security_group.davids_sg.id]

    jupyter_server_app_settings {
      default_resource_spec {
        instance_type = "ml.t2.medium"
      }
    }
  }
}

########################################
# 5️⃣ SageMaker Notebook Instance (optional, linked to user)
########################################
resource "aws_sagemaker_notebook_instance" "dave_notebook" {
  name          = "dave-notebook"
  instance_type = "ml.t2.medium"
  role_arn      = aws_iam_role.sagemaker_execution_role.arn

  # Optional: tags for tracking
  tags = {
    Project = "PredictiveMaintenancePrototype"
    User    = "dave"
  }
}
