variable "kms_key_enable_key_rotation" {
  type    = bool
  default = true
}

variable "vpc_cidr_block" {
  type = string
}

variable "kms_key_deletion_window_in_days" {
  type    = number
  default = 30
}

variable "route53_parent_zone_id" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "cloudwatch_log_expiration_days" {
  type    = number
  default = 90
}

variable "ssl_secret_certificate_bundle_keyname" { default = "CERTIFICATE_CHAIN" }
variable "ssl_secret_certificate_keyname" { default = "CERTIFICATE" }
variable "ssl_secret_certificate_private_key_keyname" { default = "CERTIFICATE_PRIVATE_KEY" }
