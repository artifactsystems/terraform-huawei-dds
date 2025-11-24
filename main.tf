locals {
  create_dds_instance = var.create_dds_instance && var.create

  # Instance name with optional prefix
  instance_name = var.use_identifier_prefix ? null : var.identifier

  # Maintenance window parsing
  maintenance_begin = var.maintenance_window != null ? split("-", var.maintenance_window)[0] : null
  maintenance_end   = var.maintenance_window != null ? split("-", var.maintenance_window)[1] : null
}

################################################################################
# DDS Instance
################################################################################

module "dds_instance" {
  count  = local.create_dds_instance ? 1 : 0
  source = "./modules/dds_instance"

  name            = local.instance_name
  use_name_prefix = var.use_identifier_prefix
  region          = var.region
  mode               = var.mode
  availability_zone  = var.availability_zone
  vpc_id             = var.vpc_id
  subnet_id          = var.subnet_id
  security_group_id  = var.security_group_id

  datastore_type        = var.datastore_type
  datastore_version     = var.datastore_version
  datastore_storage_engine = var.datastore_storage_engine

  password          = var.password
  port              = var.port
  disk_encryption_id = var.disk_encryption_id

  flavors = var.flavors

  configuration_id   = var.configuration_id
  configuration_type = var.configuration_type

  backup_strategy = var.backup_strategy

  maintain_begin = local.maintenance_begin
  maintain_end   = local.maintenance_end

  replica_set_name        = var.replica_set_name
  client_network_ranges    = var.client_network_ranges
  ssl                     = var.ssl
  second_level_monitoring_enabled = var.second_level_monitoring_enabled
  slow_log_desensitization = var.slow_log_desensitization
  balancer_status         = var.balancer_status
  balancer_active_begin   = var.balancer_active_begin
  balancer_active_end     = var.balancer_active_end

  enterprise_project_id = var.enterprise_project_id
  description          = var.description

  charging_mode = var.charging_mode
  period_unit   = var.period_unit
  period        = var.period
  auto_renew    = var.auto_renew

  tags = merge(var.tags, var.dds_instance_tags)

  timeouts = var.timeouts
}

################################################################################
# Database Users
################################################################################

locals {
  create_database_users = var.create_database_users && local.create_dds_instance
}

resource "huaweicloud_dds_database_user" "this" {
  for_each = local.create_database_users ? { for user in var.database_users : "${user.db_name}/${user.name}" => user } : {}

  instance_id = module.dds_instance[0].id
  name        = each.value.name
  password    = each.value.password
  db_name     = each.value.db_name

  dynamic "roles" {
    for_each = each.value.roles != null ? each.value.roles : []
    content {
      name    = roles.value.name
      db_name = roles.value.db_name
    }
  }

  depends_on = [module.dds_instance]
}

################################################################################
# Database Roles
################################################################################

locals {
  create_database_roles = var.create_database_roles && local.create_dds_instance
}

resource "huaweicloud_dds_database_role" "this" {
  for_each = local.create_database_roles ? { for role in var.database_roles : "${role.db_name}/${role.name}" => role } : {}

  instance_id = module.dds_instance[0].id
  name        = each.value.name
  db_name     = each.value.db_name

  dynamic "roles" {
    for_each = each.value.roles != null ? each.value.roles : []
    content {
      name    = roles.value.name
      db_name = roles.value.db_name
    }
  }

  depends_on = [module.dds_instance]
}

################################################################################
# LTS Logging
################################################################################

locals {
  create_lts_logs = var.create_lts_logs && local.create_dds_instance
}

resource "huaweicloud_dds_lts_log" "this" {
  for_each = local.create_lts_logs ? { for log in var.lts_logs : log.log_type => log } : {}

  instance_id   = module.dds_instance[0].id
  log_type      = each.value.log_type
  lts_group_id  = each.value.lts_group_id
  lts_stream_id = each.value.lts_stream_id

  depends_on = [module.dds_instance]
}

################################################################################
# Audit Log Policy
################################################################################

resource "huaweicloud_dds_audit_log_policy" "this" {
  count = var.create_audit_log_policy && local.create_dds_instance ? 1 : 0

  instance_id = module.dds_instance[0].id
  keep_days   = var.audit_log_keep_days

  audit_scope         = var.audit_log_scope
  audit_types         = var.audit_log_types
  reserve_auditlogs   = var.audit_log_reserve_auditlogs

  depends_on = [
    module.dds_instance,
    huaweicloud_dds_lts_log.this
  ]

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
}

