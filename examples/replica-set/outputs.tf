output "dds_instance_id" {
  description = "The DDS instance ID"
  value       = module.mongodb.dds_instance_id
}

output "dds_instance_name" {
  description = "The DDS instance name"
  value       = module.mongodb.dds_instance_name
}

output "dds_instance_status" {
  description = "The DDS instance status"
  value       = module.mongodb.dds_instance_status
}

output "dds_instance_port" {
  description = "The database port"
  value       = module.mongodb.dds_instance_port
}

output "dds_instance_groups" {
  description = "The instance groups information"
  value       = module.mongodb.dds_instance_groups
}

# Database Users & Roles
output "database_users" {
  description = "Map of database users created for the DDS instance"
  value       = module.mongodb.database_users
  sensitive   = true
}

output "database_roles" {
  description = "Map of database roles created for the DDS instance"
  value       = module.mongodb.database_roles
}

# LTS Logging
output "lts_logs" {
  description = "Map of LTS log configurations for the DDS instance"
  value       = module.mongodb.lts_logs
}

# Audit Log Policy
output "audit_log_policy_id" {
  description = "The audit log policy ID"
  value       = module.mongodb.audit_log_policy_id
}

