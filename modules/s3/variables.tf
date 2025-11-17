# modules/s3/variables.tf
variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

variable "s3_retention_days" {
  type    = number
  default = 30
}

variable "cors_allowed_origins" {
  type    = list(string)
  default = ["*"]
}
