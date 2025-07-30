# This is what we created manually - we should manage it with Terraform instead
# resource "aws_iam_role" "terraform_service" {
#   name = "TerraformServiceRole"
#   
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         AWS = "arn:aws:iam::${var.aws_account_id}:user/terraform-service"
#       }
#       Action = "sts:AssumeRole"
#     }]
#   })
# }
# 
# # Attach policies to role
# resource "aws_iam_role_policy_attachment" "terraform_state" {
#   role       = aws_iam_role.terraform_service.name
#   policy_arn = "arn:aws:iam::${var.aws_account_id}:policy/TerraformServicePolicy"
# }

# For now, we'll import and manage roles later
