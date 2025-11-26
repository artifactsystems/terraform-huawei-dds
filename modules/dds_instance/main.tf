resource "huaweicloud_dds_instance" "this" {
  region            = var.region
  name              = var.use_name_prefix ? null : var.name
  mode              = var.mode
  availability_zone = var.availability_zone
  vpc_id            = var.vpc_id
  subnet_id         = var.subnet_id
  security_group_id = var.security_group_id

  password           = var.password
  port               = var.port
  disk_encryption_id = var.disk_encryption_id

  datastore {
    type           = var.datastore_type
    version        = var.datastore_version
    storage_engine = var.datastore_storage_engine
  }

  dynamic "flavor" {
    for_each = var.flavors
    content {
      type      = flavor.value.type
      num       = flavor.value.num
      spec_code = flavor.value.spec_code
      storage   = try(flavor.value.storage, null)
      size      = try(flavor.value.size, null)
    }
  }

  dynamic "configuration" {
    for_each = var.configuration_id != null ? [1] : []
    content {
      type = var.configuration_type
      id   = var.configuration_id
    }
  }

  dynamic "backup_strategy" {
    for_each = var.backup_strategy != null ? [var.backup_strategy] : []
    content {
      start_time = backup_strategy.value.start_time
      keep_days  = backup_strategy.value.keep_days
      period     = try(backup_strategy.value.period, null)
    }
  }

  maintain_begin = var.maintain_begin
  maintain_end   = var.maintain_end

  replica_set_name                = var.replica_set_name
  client_network_ranges           = var.client_network_ranges
  ssl                             = var.ssl
  second_level_monitoring_enabled = var.second_level_monitoring_enabled
  slow_log_desensitization        = var.slow_log_desensitization
  balancer_status                 = var.balancer_status
  balancer_active_begin           = var.balancer_active_begin
  balancer_active_end             = var.balancer_active_end

  enterprise_project_id = var.enterprise_project_id
  description           = var.description

  charging_mode = var.charging_mode
  period_unit   = var.period_unit
  period        = var.period
  auto_renew    = var.auto_renew

  tags = var.tags

  dynamic "timeouts" {
    for_each = length(var.timeouts) > 0 ? [var.timeouts] : []
    content {
      create = try(timeouts.value.create, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      # Ignore changes to name if using name prefix
      name,
    ]
  }
}
