# Outputs
output "api_id" {
  value = aws_api_gateway_rest_api.main.id
}

output "api_url" {
  value = "https://${aws_api_gateway_rest_api.main.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/"
}

output "upload_url_endpoint" {
  value = "https://${aws_api_gateway_rest_api.main.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/upload-url"
}

output "analyze_endpoint" {
  value = "https://${aws_api_gateway_rest_api.main.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/analyze"
}

output "api_execution_arn" {
  value = aws_api_gateway_rest_api.main.execution_arn
}

