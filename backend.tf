terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket       = "toggle-master-s3-bucket"
    key          = "fase3/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true # Nativo a partir do Terraform 1.10 (elimina necessidade de tabela DynamoDB legada para lock) 
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}