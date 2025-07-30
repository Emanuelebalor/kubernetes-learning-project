provider "aws" {
  region = var.region
  
  # Removed assume_role - using direct credentials
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}
