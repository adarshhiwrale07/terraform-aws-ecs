# ------------------------------------------------------------------------------
# Service Container Definition
# ------------------------------------------------------------------------------
locals {
  container_name = module.context.name == "" ? module.context.id : module.context.name
}

module "container_definition" {
  source  = "registry.terraform.io/cloudposse/ecs-container-definition/aws"
  version = "0.58.1"

  container_image = var.container_image
  container_name  = local.container_name
  command         = var.service_command
  entrypoint      = var.container_entrypoint
  linux_parameters = null

  log_configuration = {
    logDriver : "awslogs"
    options : {
      awslogs-region : data.aws_region.current.name
      awslogs-create-group : "true"
      awslogs-group : var.cloudwatch_log_group_name
      awslogs-stream-prefix : "s"
    }
  }

  port_mappings = concat(var.container_port_mappings, [
    {
      containerPort : var.container_port
      hostPort : var.container_port
      protocol : "tcp"
    }
  ])

  map_secrets = var.secrets_map
  mount_points = var.container_mount_points
}


# ------------------------------------------------------------------------------
# Service Task
# ------------------------------------------------------------------------------
module "service" {
  source  = "registry.terraform.io/SevenPicoForks/ecs-alb-service-task/aws"
  version = "2.4.0"
  context = module.context.self

  container_definition_json = module.container_definition.json_map_encoded_list
  container_port            = var.container_port
  desired_count             = var.desired_task_count
  ecs_load_balancers        = local.load_balancers

  security_group_ids = [module.security_group.id]

  service_role_arn = ""

  task_policy_documents = length(var.task_role_policy_docs) > 0 ? [
    try(data.aws_iam_policy_document.task_policy_doc[0].json, "")
  ] : []
  task_exec_policy_documents = [try(data.aws_iam_policy_document.task_exec_policy_doc[0].json, "")]

  vpc_id          = var.vpc_id
  ecs_cluster_arn = var.cluster_arn
  subnet_ids      = var.vpc_subnet_ids
  task_cpu        = var.task_cpu
  task_memory     = var.task_memory

  platform_version                   = "1.4.0"
  propagate_tags                     = "SERVICE"
  assign_public_ip                   = var.assign_public_ip
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds  = var.create_listener_tg ? 10 : 0
  enable_ecs_managed_tags            = true
  security_group_enabled             = false
  security_group_description         = ""
  enable_all_egress_rule             = false
  enable_icmp_rule                   = false
  use_alb_security_group             = false
  alb_security_group                 = ""
  use_nlb_cidr_blocks                = false
  nlb_container_port                 = 80
  nlb_cidr_blocks                    = []
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  ordered_placement_strategy         = []
  task_placement_constraints         = []
  service_placement_constraints      = []
  network_mode                       = "awsvpc"
  deployment_controller_type         = "ECS"
  runtime_platform                   = []
  efs_volumes                        = var.efs_volumes
  docker_volumes                     = []
  proxy_configuration                = null
  ignore_changes_task_definition     = var.ignore_changes_task_definition
  ignore_changes_desired_count       = var.ignore_changes_desired_count
  capacity_provider_strategies       = []
  service_registries                 = []
  permissions_boundary               = ""
  use_old_arn                        = false
  wait_for_steady_state              = false
  task_definition                    = null
  force_new_deployment               = true
  exec_enabled                       = true
  circuit_breaker_deployment_enabled = false
  circuit_breaker_rollback_enabled   = false
  ephemeral_storage_size             = 0
  role_tags_enabled                  = true

}


# ------------------------------------------------------------------------------
# Service Security Group : [ADD RULES SEPARATELY to prevent circular dependency]
# ------------------------------------------------------------------------------
module "security_group" {
  source  = "registry.terraform.io/SevenPicoForks/security-group/aws"
  version = "3.0.0"
  context = module.context.self

  allow_all_egress           = true #changed from false
  create_before_destroy      = var.security_group_create_before_destroy
  preserve_security_group_id = var.preserve_security_group_id
  rules                      = var.security_group_rules
  rules_map                  = var.security_group_rules_map
  security_group_description = "Controls access to ${module.context.id}"
  security_group_name        = [module.context.id]
  vpc_id                     = var.vpc_id
}
