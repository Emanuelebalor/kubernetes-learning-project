terraform {
  backend "s3" {
    bucket         = "terraform-state-k8s-981360893428"
    key            = "dev/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
