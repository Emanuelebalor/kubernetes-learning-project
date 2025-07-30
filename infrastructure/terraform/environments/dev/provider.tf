provider "aws" {
  region = "eu-central-1"
  
  default_tags {
    tags = {
      Environment = "dev"
      Project     = "k8s-learning"
      ManagedBy   = "terraform"
    }
  }
}
