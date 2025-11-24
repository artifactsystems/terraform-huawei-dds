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

