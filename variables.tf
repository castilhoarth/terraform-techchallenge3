variable "aws_region" {
  description = "Região da AWS onde os recursos serão provisionados"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  type    = string
  default = "togglemaster-eks"
}

variable "cluster_version" {
  description = "Versão do K8s no EKS"
  type        = string
  default     = "1.36"
}