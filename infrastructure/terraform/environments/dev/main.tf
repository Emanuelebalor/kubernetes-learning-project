# Local values computed from variables
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Region      = var.region
  }
  
  name_prefix = "${var.project_name}-${var.environment}"
}

# Test resource to verify everything works
resource "aws_ssm_parameter" "test" {
  name  = "/${var.project_name}/${var.environment}/test"
  type  = "String"
  value = "Terraform initialized successfully at ${timestamp()}"
  
  tags = local.common_tags
}
