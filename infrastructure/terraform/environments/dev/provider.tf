provider "aws" {
  region = var.region
  
  assume_role {
    role_arn = "arn:aws:iam::981360893428:role/TerraformServiceRole"
  }
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}
