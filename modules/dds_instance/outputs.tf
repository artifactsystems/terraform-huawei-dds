output "id" {
  description = "The DDS instance ID"
  value       = huaweicloud_dds_instance.this.id
}

output "name" {
  description = "The DDS instance name"
  value       = huaweicloud_dds_instance.this.name
}

output "status" {
  description = "The DDS instance status"
  value       = huaweicloud_dds_instance.this.status
}

output "db_username" {
  description = "The DB Administrator name"
  value       = huaweicloud_dds_instance.this.db_username
}

output "port" {
  description = "The database port number"
  value       = huaweicloud_dds_instance.this.port
}

output "groups" {
  description = "The instance groups information"
  value       = huaweicloud_dds_instance.this.groups
}

output "created_at" {
  description = "The create time"
  value       = huaweicloud_dds_instance.this.created_at
}

output "updated_at" {
  description = "The update time"
  value       = huaweicloud_dds_instance.this.updated_at
}

output "time_zone" {
  description = "The time zone"
  value       = huaweicloud_dds_instance.this.time_zone
}

