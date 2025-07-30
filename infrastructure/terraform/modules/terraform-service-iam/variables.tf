variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "state_bucket_name" {
  description = "S3 bucket for Terraform state"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table for state locking"
  type        = string
}
