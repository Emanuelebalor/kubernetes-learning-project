output "role_arn" {
  description = "ARN of the Terraform service role"
  value       = aws_iam_role.terraform_service.arn
}

output "user_name" {
  description = "Name of the Terraform service user"
  value       = aws_iam_user.terraform_service.name
}
