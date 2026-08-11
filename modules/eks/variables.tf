variable "cluster_name" { type = string }
variable "subnet_ids" { type = list(string) }
variable "vpc_id" { type = string }
variable "use_academy_role" { type = bool }
variable "lab_role_arn" { type = string }