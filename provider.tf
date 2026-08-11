provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "TechChallengeFase3"
      Environment = "Production"
      ManagedBy   = "Terraform"
    }
  }
}