#------------------------------------------------------------------------------
# VPC Context
#------------------------------------------------------------------------------
module "vpc_context" {
  source  = "registry.terraform.io/SevenPico/context/null"
  version = "2.0.0"
  context = module.context.self
  name    = "vpc"
}

module "vpc_subnets_context" {
  source     = "registry.terraform.io/SevenPico/context/null"
  version    = "2.0.0"
  context    = module.vpc_context.self
  attributes = ["subnet"]
}


#------------------------------------------------------------------------------
# VPC
#------------------------------------------------------------------------------
module "vpc" {
  source  = "registry.terraform.io/cloudposse/vpc/aws"
  version = "1.1.1"
  context = module.vpc_context.legacy

  cidr_block                                      = var.vpc_cidr_block
  additional_cidr_blocks                          = []
  assign_generated_ipv6_cidr_block                = false
  classiclink_dns_support_enabled                 = false
  classiclink_enabled                             = false
  default_security_group_deny_all                 = true
  dns_hostnames_enabled                           = true
  dns_support_enabled                             = true
  enable_classiclink                              = false
  enable_default_security_group_with_custom_rules = false
  enable_classiclink_dns_support                  = false
  enable_dns_hostnames                            = true
  enable_dns_support                              = true
  enable_internet_gateway                         = true
  instance_tenancy                                = "default"
  internet_gateway_enabled                        = true
  ipv4_additional_cidr_block_associations         = {}
  ipv4_cidr_block_association_timeouts            = null
  ipv4_primary_cidr_block                         = null
  ipv4_primary_cidr_block_association             = null
  ipv6_egress_only_internet_gateway_enabled       = false
  ipv6_enabled                                    = true
  ipv6_additional_cidr_block_associations         = {}
  ipv6_cidr_block_association_timeouts            = null
  ipv6_cidr_block_network_border_group            = null
  ipv6_primary_cidr_block_association             = null
}

#------------------------------------------------------------------------------
# VPC Subnets
#------------------------------------------------------------------------------
module "vpc_subnets" {
  source  = "registry.terraform.io/cloudposse/dynamic-subnets/aws"
  version = "0.39.8"
  context = module.vpc_subnets_context.legacy

  availability_zones                   = var.availability_zones
  cidr_block                           = var.vpc_cidr_block
  igw_id                               = module.vpc.igw_id
  vpc_id                               = module.vpc.vpc_id
  availability_zone_attribute_style    = "short"
  aws_route_create_timeout             = "2m"
  aws_route_delete_timeout             = "2m"
  map_public_ip_on_launch              = false
  max_subnet_count                     = 0 // 0 means create 1 for each AZ
  metadata_http_endpoint_enabled       = false
  metadata_http_put_response_hop_limit = 1
  metadata_http_tokens_required        = true
  nat_elastic_ips                      = []
  nat_gateway_enabled                  = true
  nat_instance_enabled                 = false
  nat_instance_type                    = "t3.micro"
  private_network_acl_id               = ""
  private_subnets_additional_tags      = {}
  public_network_acl_id                = ""
  public_subnets_additional_tags       = {}
  root_block_device_encrypted          = true
  subnet_type_tag_key                  = "Type"
  subnet_type_tag_value_format         = "%s"
  vpc_default_route_table_id           = ""
}
