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

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source = "../../../terraform-huawei-vpc"

  name = local.name
  cidr = local.vpc_cidr

  azs = local.azs

  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]

  tags = local.tags
}

module "security_group" {
  source = "../../../terraform-huawei-security-group"

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

