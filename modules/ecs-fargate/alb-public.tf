## ----------------------------------------------------------------------------
##  Copyright 2023 SevenPico, Inc.
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.
## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------
##  ./ecs-alb-public.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Public Application Load Balancer
# ------------------------------------------------------------------------------
module "alb_public" {
  source     = "registry.terraform.io/SevenPicoForks/alb/aws"
  version    = "2.0.1"
  context    = module.context.self
  attributes = ["alb", "public"]

  access_logs_enabled               = false
  additional_certs                  = []
  certificate_arn                   = var.acm_certificate_arn
  cross_zone_load_balancing_enabled = true
  default_target_group_enabled      = false
  deregistration_delay              = 20
  drop_invalid_header_fields        = false
  health_check_healthy_threshold    = 2
  health_check_interval             = 300
  health_check_matcher              = "200-399"
  health_check_path                 = "/"
  health_check_port                 = 3000
  health_check_protocol             = "HTTP"
  health_check_timeout              = 120
  health_check_unhealthy_threshold  = 2
  http2_enabled                     = false
  http_enabled                      = false
  http_ingress_cidr_blocks          = []
  http_ingress_prefix_list_ids      = []
  http_port                         = 80
  http_redirect                     = false
  https_enabled                     = false
  https_ingress_cidr_blocks         = ["0.0.0.0/0"]
  https_ingress_prefix_list_ids     = []
  https_port                        = 443
  https_ssl_policy                  = var.alb_https_ssl_policy
  idle_timeout                      = 60
  internal                          = false
  ip_address_type                   = "ipv4"
  lifecycle_configuration_rules     = []
  listener_http_fixed_response      = null
  listener_https_fixed_response     = null
  load_balancer_name                = ""
  load_balancer_name_max_length     = 32
  security_group_enabled            = false
  security_group_ids                = [module.alb_public_security_group.id]
  slow_start                        = null
  stickiness                        = null
  subnet_ids                        = var.vpc_public_subnet_ids
  target_group_additional_tags      = {}
  target_group_name                 = ""
  target_group_name_max_length      = 32
  target_group_port                 = 3000
  target_group_protocol             = "HTTP"
  target_group_protocol_version     = "HTTP1"
  target_group_target_type          = "ip"
  vpc_id                            = var.vpc_id

}


# ------------------------------------------------------------------------------
# Application Load Balancer Security Group
# ------------------------------------------------------------------------------
module "alb_public_security_group" {
  source     = "registry.terraform.io/SevenPicoForks/security-group/aws"
  version    = "3.0.0"
  context    = module.context.self
  attributes = ["alb", "public"]

  allow_all_egress           = false
  create_before_destroy      = false
  inline_rules_enabled       = false
  preserve_security_group_id = true
  revoke_rules_on_delete     = false
  rules = [
    {
      key         = "alb-egress-all"
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      key         = "alb-ingress-443"
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]
  rule_matrix                   = {}
  rules_map                     = {}
  security_group_create_timeout = "10m"
  security_group_delete_timeout = "15m"
  security_group_description    = "Controls access to and from load balancer."
  security_group_name           = []
  target_security_group_id      = []
  vpc_id                        = var.vpc_id
}


# ------------------------------------------------------------------------------
# Application Load Balancer DNS
# ------------------------------------------------------------------------------
resource "aws_route53_record" "alb_public" {
  count   = module.context.enabled ? 1 : 0
  zone_id = var.route53_public_zone_id
  type    = "CNAME"
  name    = module.context.dns_name
  records = [one(module.alb_public[*].alb_dns_name)]
  ttl     = 300
}
