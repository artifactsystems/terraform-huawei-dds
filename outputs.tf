################################################################################
# DDS Instance
################################################################################

output "dds_instance_id" {
  description = "The DDS instance ID"
  value       = try(module.dds_instance[0].id, null)
}

output "dds_instance_name" {
  description = "The DDS instance name"
  value       = try(module.dds_instance[0].name, null)
}

output "dds_instance_status" {
  description = "The DDS instance status"
  value       = try(module.dds_instance[0].status, null)
}

output "dds_instance_db_username" {
  description = "The DB Administrator name"
  value       = try(module.dds_instance[0].db_username, null)
}

output "dds_instance_port" {
  description = "The database port number"
  value       = try(module.dds_instance[0].port, null)
}

output "dds_instance_groups" {
  description = "The instance groups information"
  value       = try(module.dds_instance[0].groups, null)
}

output "dds_instance_created_at" {
  description = "The create time"
  value       = try(module.dds_instance[0].created_at, null)
}

output "dds_instance_updated_at" {
  description = "The update time"
  value       = try(module.dds_instance[0].updated_at, null)
}

output "dds_instance_time_zone" {
  description = "The time zone"
  value       = try(module.dds_instance[0].time_zone, null)
}

################################################################################
# Database Users & Roles
################################################################################

output "database_users" {
  description = "Map of database users created for the DDS instance"
  value       = { for k, v in huaweicloud_dds_database_user.this : k => v }
  sensitive   = true
}

output "database_roles" {
  description = "Map of database roles created for the DDS instance"
  value       = { for k, v in huaweicloud_dds_database_role.this : k => v }
}

################################################################################
# LTS Logging
################################################################################

output "lts_logs" {
  description = "Map of LTS log configurations for the DDS instance"
  value       = { for k, v in huaweicloud_dds_lts_log.this : k => v }
}

################################################################################
# Audit Log Policy
################################################################################

output "audit_log_policy_id" {
  description = "The audit log policy ID"
  value       = try(huaweicloud_dds_audit_log_policy.this[0].id, null)
}
