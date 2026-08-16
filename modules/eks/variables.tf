variable "cluster_name" { type = string }
variable "cluster_version" { type = string }
variable "subnet_ids" { type = list(string) }
variable "vpc_id" { type = string }
variable "cluster_role_arn" { type = string }
variable "node_role_arn" { type = string }
variable "instance_types" { type = list(string) }
variable "desired_size" { type = number }
variable "min_size" { type = number }
variable "max_size" { type = number }

variable "use_academy_role" {
  type        = bool
  default     = false
  description = "Flag para desativar comportamento do AWS Academy"
}