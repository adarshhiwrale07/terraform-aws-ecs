variable "vpc_id" {
  type = string
}

variable "vpc_subnet_ids" {
  type    = list(string)
  default = []
}

variable "assign_public_ip" {
  type    = bool
  default = false
}

variable "cluster_arn" {
  type = string
}

variable "cloudwatch_log_group_name" {
  type    = string
  default = ""
}

variable "desired_task_count" {
  type    = number
  default = 1
}

variable "task_cpu" {
  default = 1024
}

variable "task_memory" {
  default = 2048
}

variable "ignore_changes_task_definition" {
  type    = bool
  default = true
}

variable "ignore_changes_desired_count" {
  type    = bool
  default = false
}

variable "container_image" {
  type = string
}

variable "container_port" {
  type = number
}

variable "service_command" {
  type    = list(string)
  default = []
}

variable "container_entrypoint" {
  type    = list(string)
  default = null
}

variable "container_port_mappings" {
  default = []
}

variable "preserve_security_group_id" {
  type    = bool
  default = true
}

variable "security_group_create_before_destroy" {
  type    = bool
  default = false
}

variable "task_role_policy_docs" {
  type    = map(string)
  default = {}
}

variable "task_exec_role_policy_docs" {
  type    = map(string)
  default = {}
}

variable "service_role_policy_docs" {
  type    = list(string)
  default = []
}

variable "security_group_rules_map" {
  type    = any
  default = {}
}

variable "security_group_rules" {
  type        = any
  default     = []
  description = <<EOF
Example as follows:
[
  {
    key                      = "ingress-from-$${module.alb_context.id}"
    description              = "Allow ingress from ALB to service"
    type                     = "ingress"
    protocol                 = "tcp"
    from_port                = var.container_port
    to_port                  = var.container_port
    source_security_group_id = module.alb_security_group.id
  }
]
EOF
}

variable "load_balancer_arn" {
  type = string
}

variable "create_listener_tg" {
  type = bool
}

variable "secrets_map" {
  type    = map(string)
  default = {}
}

variable "health_check_protocol" {
  type = string
}
variable "health_check_port" {
  type = number

}
variable "health_check_path" {
  type    = string
  default = "/"
}

variable "health_check_interval" {
  type    = number
  default = 40 #seconds
}

variable "health_check_timeout" {
  type    = number
  default = 30 #seconds
}

variable "target_group_protocol" {
  type    = string
  default = "HTTPS"
}

variable "target_group_type" {
  type    = string
  default = "ip"
}

variable "listener_protocol" {
  type    = string
  default = ""
}

variable "alb_https_ssl_policy" {
  type = string
}

variable "acm_certificate_arn" {
  type = string
}

variable "ssl_policy" {
  type    = string
  default = ""
}

variable "efs_volumes" {
  type = list(object({
    host_path = string
    name      = string
    efs_volume_configuration = list(object({
      file_system_id          = string
      root_directory          = string
      transit_encryption      = string
      transit_encryption_port = string
      authorization_config = list(object({
        access_point_id = string
        iam             = string
      }))
    }))
  }))

  description = "Task EFS volume definitions as list of configuration objects. You can define multiple EFS volumes on the same task definition, but a single volume can only have one `efs_volume_configuration`."
  default     = []
}

variable "container_mount_points" {
  type = list(object({
    containerPath : string
    sourceVolume : string
    readOnly : bool
  }))
  default     = []
  description = "Task Container Mount Points."
}

variable "preserve_if_disabled" {
  type    = bool
  default = true
}