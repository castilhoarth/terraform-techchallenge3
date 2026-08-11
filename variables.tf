variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "use_academy-role" {
  type        = bool
  default     = true
  description = "Define se deve utilizar o LabRole padrão do AWS Academy"
}

variable "lab_role_arn" {
  type        = string
  default     = "arn:aws:iam::111969794439:role/LabRole" # Substitua pelo seu Account ID
  description = "ARN da LabRole do AWS Academy"
}