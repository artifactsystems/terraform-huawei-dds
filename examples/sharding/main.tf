provider "huaweicloud" {
  region = local.region
}

data "huaweicloud_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "tr-west-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.huaweicloud_availability_zones.available.names, 0, 1)

  tags = {
    Name    = local.name
    Example = local.name
  }
}

################################################################################
# DDS Module - Cluster Community Edition (Sharding)
################################################################################

module "mongodb_cluster" {
  source = "../../"

  identifier = local.name

  mode              = "Sharding"
  availability_zone = local.azs[0]
  vpc_id            = module.vpc.vpc_id
  subnet_id         = module.vpc.private_subnets[0]
  security_group_id = module.security_group.security_group_id

  datastore_version        = "4.0"
  datastore_storage_engine = "wiredTiger"

  password = "YourPassword@123"

  flavors = [
    {
      type      = "mongos"
      num       = 2
      spec_code = "dds.mongodb.s6.medium.4.mongos"
    },
    {
      type      = "shard"
      num       = 2
      storage   = "ULTRAHIGH"
      size      = 20
      spec_code = "dds.mongodb.s6.medium.4.shard"
    },
    {
      type      = "config"
      num       = 1
      storage   = "ULTRAHIGH"
      size      = 20
      spec_code = "dds.mongodb.s6.large.2.config"
    }
  ]

  backup_strategy = {
    start_time = "08:00-09:00"
    keep_days  = 8
  }

  maintenance_window = "02:00-03:00"

  # Database Users & Roles
  create_database_users = true
  database_users = [
    {
      name     = "appuser"
      password = "AppUser123!"
      db_name  = "admin"
      roles = [
        {
          name    = "readWrite"
          db_name = "admin"
        }
      ]
    }
  ]

  create_database_roles = true
  database_roles = [
    {
      name    = "readonly_role"
      db_name = "admin"
      roles = [
        {
          name    = "read"
          db_name = "admin"
        }
      ]
    }
  ]

  # LTS Logging
  create_lts_logs = true
  lts_logs = [
    {
      log_type     = "audit_log"
      lts_group_id = module.lts.log_group_id
      lts_stream_id = module.lts.log_stream_ids["${local.name}-audit-log"]
    }
  ]

  # Audit Log Policy
  create_audit_log_policy = true
  audit_log_keep_days     = 30
  audit_log_scope         = "all"
  audit_log_types         = ["auth", "insert", "delete", "update", "query", "command"]

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source = "github.com/artifactsystems/terraform-huawei-vpc?ref=v1.0.0"

  name = local.name
  cidr = local.vpc_cidr

  azs = local.azs

  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]

  tags = local.tags
}

module "security_group" {
  source = "github.com/artifactsystems/terraform-huawei-security-group?ref=v1.0.0"

  name        = local.name
  description = "Sharding MongoDB cluster example security group"

  ingress_with_cidr_blocks = [
    {
      from_port   = 8635
      to_port     = 8635
      protocol    = "tcp"
      description = "MongoDB access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  tags = local.tags
}

module "lts" {
  source = "github.com/artifactsystems/terraform-huawei-lts?ref=v1.0.0"

  group_name  = "${local.name}-logs"
  ttl_in_days = 30

  log_streams = [
    {
      name        = "${local.name}-audit-log"
      ttl_in_days = 30
    }
  ]

  tags = local.tags
}

