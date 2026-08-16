provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project      = "TechChallenge"
      Application  = "ToggleMaster"
      Phase        = "Fase 3"
      Environment  = "Production"
      ManagedBy    = "Terraform"
      Architecture = "Microservices"
    }
  }
}