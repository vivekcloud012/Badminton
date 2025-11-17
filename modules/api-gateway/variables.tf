# modules/api-gateway/variables.tf
variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "analysis_lambda_arn" {
  type = string
}

variable "analysis_lambda_invoke_arn" {
  type = string
}

variable "analysis_lambda_function_name" {
  type = string
}

variable "upload_lambda_arn" {
  type = string
}

variable "upload_lambda_invoke_arn" {
  type = string
}

variable "upload_lambda_function_name" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

variable "api_stage_name" {
  type    = string
  default = "v1"
}

data "aws_region" "current" {}
