# modules/lambda/outputs.tf
output "analysis_lambda_arn" {
  value = aws_lambda_function.analysis.arn
}

output "analysis_lambda_invoke_arn" {
  value = aws_lambda_function.analysis.invoke_arn
}

output "analysis_lambda_function_name" {
  value = aws_lambda_function.analysis.function_name
}

output "upload_lambda_arn" {
  value = aws_lambda_function.upload.arn
}

output "upload_lambda_invoke_arn" {
  value = aws_lambda_function.upload.invoke_arn
}

output "upload_lambda_function_name" {
  value = aws_lambda_function.upload.function_name
}
