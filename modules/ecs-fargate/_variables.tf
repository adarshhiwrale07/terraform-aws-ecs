variable "vpc_id" {
  type = string
}

variable "route53_public_zone_id" {
  type = string
}

variable "s3_force_destroy" {
  type    = bool
  default = false
}

variable "cloudwatch_log_expiration_days" {
  type    = number
  default = 90
}

variable "acm_certificate_arn" {
  type = string
}

variable "vpc_public_subnet_ids" {
  type = list(string)
}

variable "vpc_private_subnet_ids" {
  type = list(string)
}

variable "alb_https_ssl_policy" {
  type = string
}

variable "container_image" {
  type = string
}

variable "container_port" {
  type = number
}

variable "task_cpu" {
  default = 256
}

variable "task_memory" {
  default = 512
}

variable "service_command" {
  type    = list(string)
  default = []
}
