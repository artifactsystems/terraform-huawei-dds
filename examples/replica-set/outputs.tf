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

