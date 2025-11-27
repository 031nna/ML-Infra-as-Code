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

###########################
# IAM ROLE FOR SAGEMAKER
###########################

resource "aws_iam_role" "sagemaker_execution_role" {
  name = "sagemaker-execution-role" # REQUIRED

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Minimal permissions for SageMaker to access S3 + CloudWatch
resource "aws_iam_role_policy" "sagemaker_policy" {
  name = "sagemaker-policy"
  role = aws_iam_role.sagemaker_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect : "Allow",
        Action : [
          "s3:*",
          "logs:*"
        ],
        Resource : "*"
      }
    ]
  })
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

###########################
# PREBUILT CONTAINER IMAGE
###########################

data "aws_sagemaker_prebuilt_ecr_image" "test" {
  repository_name = "kmeans"
  tag             = "1" # specify a tag (required in most regions)
}

###########################
# SAGEMAKER MODEL
###########################

resource "aws_sagemaker_model" "sagemaker_execution_model" {
  name               = "my-model"
  execution_role_arn = aws_iam_role.sagemaker_execution_role.arn

  primary_container {
    image = data.aws_sagemaker_prebuilt_ecr_image.test.registry_path

    # Optional: environment variables for inference
    environment = {
      SAGEMAKER_PROGRAM = "inference.py"
    }
  }
}
