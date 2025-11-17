# outputs.tf
output "api_gateway_url" {
  description = "Base URL for API Gateway"
  value       = module.api_gateway.api_url
}

output "upload_url_endpoint" {
  description = "Full URL for upload-url endpoint"
  value       = module.api_gateway.upload_url_endpoint
}

output "analyze_endpoint" {
  description = "Full URL for analyze endpoint"
  value       = module.api_gateway.analyze_endpoint
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for video storage"
  value       = module.s3_bucket.bucket_name
}

output "analysis_lambda_function_name" {
  description = "Name of the analysis Lambda function"
  value       = module.lambda_functions.analysis_lambda_function_name
}

output "upload_lambda_function_name" {
  description = "Name of the upload Lambda function"
  value       = module.lambda_functions.upload_lambda_function_name
}

output "cloudwatch_log_groups" {
  description = "CloudWatch log groups for Lambda functions"
  value = {
    analysis = "/aws/lambda/badminton-analysis-analysis-${var.environment}"
    upload   = "/aws/lambda/badminton-analysis-upload-${var.environment}"
  }
}

output "api_endpoints" {
  description = "Available API endpoints with examples"
  value = {
    upload_url = "${module.api_gateway.api_url}upload-url?filename=test.mp4"
    analyze    = "${module.api_gateway.api_url}analyze"
  }
}
