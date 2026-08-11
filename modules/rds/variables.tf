variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "eks_security_group_id" { type = string }
variable "databases" { type = list(string) }