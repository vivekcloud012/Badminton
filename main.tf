# main.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Local variables
locals {
  project_name = "badminton-analysis"
  common_tags = {
    Project     = local.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# S3 Module
module "s3_bucket" {
  source = "./modules/s3"

  project_name    = local.project_name
  environment     = var.environment
  common_tags     = local.common_tags
}

# IAM Module
module "iam_roles" {
  source = "./modules/iam"

  project_name    = local.project_name
  environment     = var.environment
  s3_bucket_arn   = module.s3_bucket.bucket_arn
  account_id      = data.aws_caller_identity.current.account_id
  region          = data.aws_region.current.name
  common_tags     = local.common_tags
}

# Lambda Module
module "lambda_functions" {
  source = "./modules/lambda"

  project_name          = local.project_name
  environment           = var.environment
  s3_bucket_name        = module.s3_bucket.bucket_name
  lambda_role_arn       = module.iam_roles.lambda_role_arn
  common_tags           = local.common_tags

  depends_on = [module.iam_roles]
}

# API Gateway Module
# main.tf - Fix the API Gateway module section
module "api_gateway" {
  source = "./modules/api-gateway"

  project_name                    = local.project_name
  environment                     = var.environment
  analysis_lambda_arn             = module.lambda_functions.analysis_lambda_arn
  analysis_lambda_invoke_arn      = module.lambda_functions.analysis_lambda_invoke_arn
  analysis_lambda_function_name   = module.lambda_functions.analysis_lambda_function_name
  upload_lambda_arn               = module.lambda_functions.upload_lambda_arn
  upload_lambda_invoke_arn        = module.lambda_functions.upload_lambda_invoke_arn
  upload_lambda_function_name     = module.lambda_functions.upload_lambda_function_name
  common_tags                     = local.common_tags
  api_stage_name                  = var.api_stage_name

  depends_on = [
    module.lambda_functions,
  ]
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "lambda_logs" {
  for_each = toset(["analysis", "upload"])

  name              = "/aws/lambda/${local.project_name}-${each.key}-${var.environment}"
  retention_in_days = 14
  tags              = local.common_tags
}

# Bedrock Access Policy
resource "aws_iam_policy" "bedrock_access" {
  name        = "${local.project_name}-bedrock-access-${var.environment}"
  description = "Policy for accessing Amazon Bedrock"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:ListFoundationModels"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_bedrock" {
  role       = module.iam_roles.lambda_role_name
  policy_arn = aws_iam_policy.bedrock_access.arn
}

# SageMaker Access Policy
resource "aws_iam_policy" "sagemaker_access" {
  name        = "${local.project_name}-sagemaker-access-${var.environment}"
  description = "Policy for accessing Amazon SageMaker"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sagemaker:InvokeEndpoint",
          "sagemaker:ListEndpoints"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sagemaker" {
  role       = module.iam_roles.lambda_role_name
  policy_arn = aws_iam_policy.sagemaker_access.arn
}
