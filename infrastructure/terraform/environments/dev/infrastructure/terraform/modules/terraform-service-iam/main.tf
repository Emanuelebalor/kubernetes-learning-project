# The user (already exists, we'll import it)
resource "aws_iam_user" "terraform_service" {
  name = "terraform-service"
}

# The role
resource "aws_iam_role" "terraform_service" {
  name = "TerraformServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = aws_iam_user.terraform_service.arn
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Backend access policy
resource "aws_iam_policy" "terraform_backend" {
  name        = "TerraformBackendPolicy"
  description = "S3 and DynamoDB access for Terraform state"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "TerraformStateS3Bucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketVersioning",
          "s3:GetBucketLocation"
        ]
        Resource = "arn:aws:s3:::${var.state_bucket_name}"
      },
      {
        Sid    = "TerraformStateS3Objects"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::${var.state_bucket_name}/*"
      },
      {
        Sid    = "TerraformStateLocking"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = "arn:aws:dynamodb:*:${var.aws_account_id}:table/${var.dynamodb_table_name}"
      }
    ]
  })
}

# SSM policy
resource "aws_iam_policy" "terraform_ssm" {
  name        = "TerraformSSMPolicy"
  description = "SSM Parameter Store access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SSMParameterAccess"
        Effect = "Allow"
        Action = [
          "ssm:PutParameter",
          "ssm:GetParameter",
          "ssm:DeleteParameter",
          "ssm:AddTagsToResource",
          "ssm:ListTagsForResource",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "arn:aws:ssm:*:${var.aws_account_id}:parameter/k8s-learning/*"
      },
      {
        Sid      = "SSMDescribeParameters"
        Effect   = "Allow"
        Action   = ["ssm:DescribeParameters"]
        Resource = "*"
      }
    ]
  })
}

# User policy to assume role
resource "aws_iam_policy" "assume_role" {
  name        = "TerraformAssumeRolePolicy"
  description = "Allow terraform-service to assume TerraformServiceRole"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "AssumeTerraformRole"
      Effect   = "Allow"
      Action   = "sts:AssumeRole"
      Resource = aws_iam_role.terraform_service.arn
    }]
  })
}

# Attach policies to role
resource "aws_iam_role_policy_attachment" "backend" {
  role       = aws_iam_role.terraform_service.name
  policy_arn = aws_iam_policy.terraform_backend.arn
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.terraform_service.name
  policy_arn = aws_iam_policy.terraform_ssm.arn
}

# Attach assume role policy to user
resource "aws_iam_user_policy_attachment" "assume_role" {
  user       = aws_iam_user.terraform_service.name
  policy_arn = aws_iam_policy.assume_role.arn
}
