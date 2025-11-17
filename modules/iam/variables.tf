# modules/iam/variables.tf
variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "s3_bucket_arn" {
  type = string
}

variable "account_id" {
  type = string
}

variable "region" {
  type = string
}

variable "common_tags" {
  type = map(string)
}
