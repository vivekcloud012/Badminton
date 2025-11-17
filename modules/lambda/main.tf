# modules/lambda/main.tf
data "archive_file" "analysis_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambda-src/analysis"
  output_path = "${path.module}/analysis_lambda.zip"
}

data "archive_file" "upload_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambda-src/upload"
  output_path = "${path.module}/upload_lambda.zip"
}

resource "aws_lambda_function" "analysis" {
  filename         = data.archive_file.analysis_lambda.output_path
  function_name    = "${var.project_name}-analysis-${var.environment}"
  role            = var.lambda_role_arn
  handler         = "lambda_function.lambda_handler"
  runtime         = "python3.9"
  timeout         = 300
  memory_size     = 512

  environment {
    variables = {
      BUCKET_NAME        = var.s3_bucket_name
      ENVIRONMENT        = var.environment
      PROJECT_NAME       = var.project_name
    }
  }

  tags = var.common_tags

  depends_on = [
    data.archive_file.analysis_lambda,
  ]
}

resource "aws_lambda_function" "upload" {
  filename         = data.archive_file.upload_lambda.output_path
  function_name    = "${var.project_name}-upload-${var.environment}"
  role            = var.lambda_role_arn
  handler         = "lambda_function.lambda_handler"
  runtime         = "python3.9"
  timeout         = 60
  memory_size     = 128

  environment {
    variables = {
      BUCKET_NAME        = var.s3_bucket_name
      ENVIRONMENT        = var.environment
    }
  }

  tags = var.common_tags

  depends_on = [
    data.archive_file.upload_lambda,
  ]
}
