module "ecs_fargate" {
  source  = "./modules/ecs-fargate"
  context = module.context.self
  enabled = module.context.enabled
  name    = "nodejs"

  acm_certificate_arn                        = module.ssl_certificate.acm_certificate_arn
  alb_https_ssl_policy                       = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  container_image                            = "664439523244.dkr.ecr.us-east-1.amazonaws.com/nodejs:latest"
  container_port                             = 3000
  route53_public_zone_id                     = var.route53_parent_zone_id
  service_command                            = []
  vpc_id                                     = module.vpc.vpc_id
  vpc_public_subnet_ids                      = module.vpc_subnets.public_subnet_ids
  vpc_private_subnet_ids                     = module.vpc_subnets.private_subnet_ids
  cloudwatch_log_expiration_days             = var.cloudwatch_log_expiration_days
  task_cpu = 512
  task_memory = 1024
}