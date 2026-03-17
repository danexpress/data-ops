variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  default= "dml-temperature-analysis"
  description = "The project name"
}

variable "use_existing_bucket" {
  description = "set to true to use an existing S3 bucket instead of creating a new one"
  type        = bool
  default     = false
}

variable "existing_bucket_name" {
  description = "The name of the existing S3 bucket"
  type        = string
  default     = "dml-temperature-analysis-raw-data"
}
