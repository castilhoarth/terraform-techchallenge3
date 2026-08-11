# 1. Networking (VPC)
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = "10.0.0.0/16"
  public_subnets_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets_cidr = ["10.0.10.0/24", "10.0.11.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
  cluster_name         = "tech-challenge-cluster"
}

# 2. Cluster (EKS)
module "eks" {
  source = "./modules/eks"

  cluster_name     = "tech-challenge-cluster"
  subnet_ids       = module.vpc.public_subnet_ids
  vpc_id           = module.vpc.vpc_id
  use_academy_role = var.use_academy-role
  lab_role_arn     = var.lab_role_arn
}

# 3. Banco de Dados (RDS)
module "rds" {
  source = "./modules/rds"

  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.private_subnet_ids
  eks_security_group_id = module.eks.cluster_security_group_id

  databases = ["db1", "db2", "db3"] # Instaâncias RDS
}

module "elasticache" {
  source                = "./modules/elasticache"
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.private_subnet_ids
  eks_security_group_id = module.eks.cluster_security_group_id
}

module "dynamodb" {
  source = "./modules/dynamodb"

  table_name = "ToggleMasterAnalytics"
}

# 4. Mensageria (SQS)
module "sqs" {
  source = "./modules/sqs"

  queue_name = "tech-challenge-events-queue"
}

# 5. Repositórios ECR
module "ecr" {
  source = "./modules/ecr"
  repository_names = [
    "app-auth",
    "app-orders",
    "app-payments",
    "app-analytics",
    "app-notifications"
  ]
}