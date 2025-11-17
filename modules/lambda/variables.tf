# modules/lambda/variables.tf
variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}

variable "lambda_role_arn" {
  type = string
}

variable "common_tags" {
  type = map(string)
}
