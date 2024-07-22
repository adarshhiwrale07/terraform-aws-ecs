#------------------------------------------------------------------------------
# ECS Context
#------------------------------------------------------------------------------
module "ecs_cluster_context" {
  source     = "registry.terraform.io/SevenPico/context/null"
  version    = "2.0.0"
  context    = module.context.self
  enabled    = module.context.enabled
  attributes = ["cluster"]
}

module "ecs_task_exec_policy_context" {
  source     = "registry.terraform.io/SevenPico/context/null"
  version    = "2.0.0"
  context    = module.context.self
  attributes = ["ecs-nodejs-task-exec-policy"]
}

module "ecs_service_context" {
  source  = "registry.terraform.io/SevenPico/context/null"
  version = "2.0.0"
  context = module.context.self
  name    = "nodejs"
}


#------------------------------------------------------------------------------
# ECS Cluster
#------------------------------------------------------------------------------
resource "aws_ecs_cluster" "core" {
  count = module.ecs_cluster_context.enabled ? 1 : 0
  name  = module.ecs_cluster_context.id
  tags  = module.ecs_cluster_context.tags
}


#------------------------------------------------------------------------------
# ECS Cloudwatch Log Group for Services
#------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "ecs_services" {
  count             = module.ecs_cluster_context.enabled ? 1 : 0
  name              = "/aws/ecs/${aws_ecs_cluster.core[0].name}/services"
  retention_in_days = var.cloudwatch_log_expiration_days
}


#------------------------------------------------------------------------------
# ECS Cloudwatch Log Group for Tasks
#------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "ecs_tasks" {
  count             = module.ecs_cluster_context.enabled ? 1 : 0
  name              = "/aws/ecs/${aws_ecs_cluster.core[0].name}/tasks"
  retention_in_days = var.cloudwatch_log_expiration_days
}


# ------------------------------------------------------------------------------
# ECS IAM
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "ecs_task_exec_policy_doc" {
  #checkov:skip=CKV_AWS_356:skipping 'Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions'
  count = module.ecs_task_exec_policy_context.enabled ? 1 : 0
  statement {
    sid    = "SSMParameter"
    effect = "Allow"
    actions = [
      "ssm:GetParameters"
    ]
    resources = ["*"]
  }
}


#------------------------------------------------------------------------------
# Ecs Fargate
#------------------------------------------------------------------------------
module "ecs_service" {
  source  = "./service"
  context = module.ecs_service_context.self

  create_listener_tg                   = true
  acm_certificate_arn                  = var.acm_certificate_arn
  assign_public_ip                     = false
  cloudwatch_log_group_name            = try(aws_cloudwatch_log_group.ecs_services[0].name, "")
  cluster_arn                          = try(aws_ecs_cluster.core[0].arn, "")
  container_entrypoint                 = []
  container_image                      = var.container_image
  container_port                       = var.container_port
  container_port_mappings              = []
  desired_task_count                   = 1
  efs_volumes                          = []
  health_check_path                    = "/"
  health_check_port                    = var.container_port
  health_check_protocol                = "HTTP"
  health_check_interval                = 40
  health_check_timeout                 = 30
  ignore_changes_desired_count         = true
  ignore_changes_task_definition       = true
  listener_protocol                    = "HTTPS"
  alb_https_ssl_policy                 = var.alb_https_ssl_policy
  load_balancer_arn                    = module.alb_public.alb_arn
  container_mount_points               = []
  preserve_security_group_id           = true
  secrets_map                          = {}
  security_group_create_before_destroy = false
  security_group_rules = [
    {
      key                      = "IngressFromAlb"
      description              = "Allow ingress from ALB."
      type                     = "ingress"
      protocol                 = "tcp"
      from_port                = 3000
      to_port                  = 3000
      cidr_blocks              = []
      source_security_group_id = module.alb_public_security_group.id
    },
  ]
  security_group_rules_map   = {}
  service_command            = var.service_command
  service_role_policy_docs   = []
  target_group_protocol      = "HTTP"
  target_group_type          = "ip"
  task_cpu                   = var.task_cpu
  task_memory                = var.task_memory
  task_exec_role_policy_docs = { default : try(data.aws_iam_policy_document.ecs_task_exec_policy_doc[0].json, {}) }
  vpc_id                     = var.vpc_id
  vpc_subnet_ids             = var.vpc_private_subnet_ids
}
