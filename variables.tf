################################################################################
# General
################################################################################

variable "create" {
  description = "Whether to create DDS resources"
  type        = bool
  default     = true
}

variable "region" {
  description = "The Huawei Cloud region where resources will be created. If not specified, the region configured in the provider will be used"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

variable "dds_instance_tags" {
  description = "Additional tags for the DDS instance"
  type        = map(string)
  default     = {}
}

################################################################################
# DDS Instance
################################################################################

variable "create_dds_instance" {
  description = "Whether to create a DDS instance"
  type        = bool
  default     = true
}

variable "identifier" {
  description = "The name of the DDS instance. Must be 4 to 64 characters and start with a letter"
  type        = string
}

variable "use_identifier_prefix" {
  description = "Determines whether to use `identifier` as is or create a unique identifier beginning with `identifier` as the specified prefix"
  type        = bool
  default     = false
}

variable "mode" {
  description = "Specifies the mode of the database instance. Valid values: Sharding, ReplicaSet"
  type        = string

  validation {
    condition     = contains(["Sharding", "ReplicaSet"], var.mode)
    error_message = "Mode must be either 'Sharding' or 'ReplicaSet'."
  }
}

variable "availability_zone" {
  description = "Specifies the availability zone names separated by commas"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the DDS instance will be created"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID where the DDS instance will be created"
  type        = string
}

variable "security_group_id" {
  description = "The security group ID to associate with the DDS instance"
  type        = string
}

################################################################################
# Datastore Configuration
################################################################################

variable "datastore_type" {
  description = "Specifies the DB engine. Currently only 'DDS-Community' is supported"
  type        = string
  default     = "DDS-Community"
}

variable "datastore_version" {
  description = "Specifies the DB instance version. Valid values: 4.0, 4.2, 4.4, 5.0"
  type        = string
}

variable "datastore_storage_engine" {
  description = <<-EOF
    Specifies the storage engine of the DB instance.
    - For version 4.0: wiredTiger
    - For versions 4.2, 4.4, 5.0: rocksDB
    If not specified, defaults based on version
  EOF
  type        = string
  default     = null
}

################################################################################
# Authentication & Access
################################################################################

variable "password" {
  description = "Specifies the Administrator password of the database instance. Must be 8-32 characters long and contain at least three types: uppercase letters, lowercase letters, digits, and special characters"
  type        = string
  sensitive   = true
}

variable "port" {
  description = "Specifies the database access port. Valid values: 2100-9500, 27017, 27018, 27019. Defaults to 8635"
  type        = number
  default     = null
}

variable "disk_encryption_id" {
  description = "Specifies the disk encryption ID of the instance"
  type        = string
  default     = null
}

################################################################################
# Flavor Configuration
################################################################################

variable "flavors" {
  description = <<-EOF
    List of flavor configurations for the DDS instance.
    
    For Sharding mode:
    - mongos: type = "mongos", num = 2-16, spec_code required, storage/size not applicable
    - shard: type = "shard", num = 2-16, spec_code required, storage/size required
    - config: type = "config", num = 1, spec_code required, storage/size required
    
    For ReplicaSet mode:
    - replica: type = "replica", num = 3/5/7, spec_code required, storage/size required
    
    Example for Sharding:
    [
      {
        type      = "mongos"
        num       = 2
        spec_code = "dds.mongodb.c3.medium.4.mongos"
      },
      {
        type      = "shard"
        num       = 2
        storage   = "ULTRAHIGH"
        size      = 20
        spec_code = "dds.mongodb.c3.medium.4.shard"
      },
      {
        type      = "config"
        num       = 1
        storage   = "ULTRAHIGH"
        size      = 20
        spec_code = "dds.mongodb.c3.large.2.config"
      }
    ]
    
    Example for ReplicaSet:
    [
      {
        type      = "replica"
        num       = 3
        storage   = "ULTRAHIGH"
        size      = 30
        spec_code = "dds.mongodb.c3.medium.4.repset"
      }
    ]
  EOF
  type = list(object({
    type      = string
    num       = number
    spec_code = string
    storage   = optional(string)
    size      = optional(number)
  }))
}

################################################################################
# Configuration Template
################################################################################

variable "configuration_id" {
  description = "Specifies the ID of the parameter template to use"
  type        = string
  default     = null
}

variable "configuration_type" {
  description = "Specifies the node type for configuration. Valid values: mongos, shard, config (for Sharding), replica (for ReplicaSet)"
  type        = string
  default     = null
}

################################################################################
# Backup Strategy
################################################################################

variable "backup_strategy" {
  description = <<-EOF
    Backup strategy configuration for automated backups.
    
    Example:
    {
      start_time = "08:00-09:00"
      keep_days  = 8
      period     = "1,3,5"  # Optional, backup cycle (days of week: 1=Monday, 7=Sunday)
    }
  EOF
  type = object({
    start_time = string
    keep_days  = number
    period     = optional(string)
  })
  default = null
}

################################################################################
# Maintenance Window
################################################################################

variable "maintenance_window" {
  description = "The maintenance window for the DDS instance. Format: 'HH:MM-HH:MM' in UTC+0. Example: '02:00-03:00'"
  type        = string
  default     = null
}

################################################################################
# ReplicaSet Specific Settings
################################################################################

variable "replica_set_name" {
  description = "Specifies the name of the replica set in the connection address. Must be 3-128 characters, start with a letter. Default is 'replica'"
  type        = string
  default     = null
}

variable "client_network_ranges" {
  description = "Specifies the CIDR block where the client is located. Cross-CIDR access is required only when the CIDR blocks of the client and the replica set instance are different. Only for ReplicaSet mode"
  type        = list(string)
  default     = []
}

################################################################################
# Advanced Settings
################################################################################

variable "ssl" {
  description = "Specifies whether to enable or disable SSL. Defaults to true. NOTE: The instance will be restarted when switching SSL"
  type        = bool
  default     = null
}

variable "second_level_monitoring_enabled" {
  description = "Specifies whether to enable second level monitoring"
  type        = bool
  default     = null
}

variable "slow_log_desensitization" {
  description = "Specifies whether to enable slow original log. Valid values: 'on', 'off'"
  type        = string
  default     = null
}

variable "balancer_status" {
  description = "Specifies the status of the balancer. Valid values: 'start', 'stop'. Defaults to 'start'. Only for Sharding mode"
  type        = string
  default     = null
}

variable "balancer_active_begin" {
  description = "Specifies the start time of the balancing activity time window. Format: HH:MM in UTC. Required with balancer_active_end. Only for Sharding mode"
  type        = string
  default     = null
}

variable "balancer_active_end" {
  description = "Specifies the end time of the balancing activity time window. Format: HH:MM in UTC. Required with balancer_active_begin. Only for Sharding mode"
  type        = string
  default     = null
}

variable "enterprise_project_id" {
  description = "The enterprise project ID for the DDS instance"
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the DDS instance"
  type        = string
  default     = null
}

################################################################################
# Billing Configuration
################################################################################

variable "charging_mode" {
  description = "Specifies the charging mode of the DDS instance. Valid values: 'prePaid' (yearly/monthly), 'postPaid' (pay-per-use, default)"
  type        = string
  default     = "postPaid"

  validation {
    condition     = contains(["prePaid", "postPaid"], var.charging_mode)
    error_message = "charging_mode must be either 'prePaid' or 'postPaid'."
  }
}

variable "period_unit" {
  description = "Specifies the charging period unit. Required when charging_mode is 'prePaid'. Valid values: 'month', 'year'"
  type        = string
  default     = null
}

variable "period" {
  description = "Specifies the charging period. Required when charging_mode is 'prePaid'. Valid: 1-9 (month), 1-3 (year)"
  type        = number
  default     = null
}

variable "auto_renew" {
  description = "Specifies whether to automatically renew prepaid instance. Valid values: 'true', 'false'"
  type        = string
  default     = null
}

################################################################################
# Database Users & Roles
################################################################################

variable "create_database_users" {
  description = "Whether to create database users for the DDS instance"
  type        = bool
  default     = false
}

variable "database_users" {
  description = <<-EOF
    List of database users to create for the DDS instance.
    
    Example:
    [
      {
        name     = "appuser"
        password = "SecurePassword123!"
        db_name  = "mydb"
        roles = [
          {
            name    = "readWrite"
            db_name = "mydb"
          }
        ]
      }
    ]
  EOF
  type = list(object({
    name     = string
    password = string
    db_name  = string
    roles    = optional(list(object({
      name    = string
      db_name = string
    })), [])
  }))
  default = []
}

variable "create_database_roles" {
  description = "Whether to create database roles for the DDS instance"
  type        = bool
  default     = false
}

variable "database_roles" {
  description = <<-EOF
    List of database roles to create for the DDS instance.
    
    Example:
    [
      {
        name    = "readonly_role"
        db_name = "mydb"
        roles = [
          {
            name    = "read"
            db_name = "mydb"
          }
        ]
      }
    ]
  EOF
  type = list(object({
    name    = string
    db_name = string
    roles   = optional(list(object({
      name    = string
      db_name = string
    })), [])
  }))
  default = []
}

################################################################################
# LTS Logging
################################################################################

variable "create_lts_logs" {
  description = "Whether to create LTS log configurations for the DDS instance"
  type        = bool
  default     = false
}

variable "lts_logs" {
  description = <<-EOF
    List of LTS log configurations for the DDS instance.
    
    Example:
    [
      {
        log_type     = "audit_log"
        lts_group_id = "group-id-xxxxx"
        lts_stream_id = "stream-id-xxxxx"
      }
    ]
  EOF
  type = list(object({
    log_type     = string
    lts_group_id = string
    lts_stream_id = string
  }))
  default = []
}

################################################################################
# Audit Log Policy
################################################################################

variable "create_audit_log_policy" {
  description = "Whether to create an audit log policy for the DDS instance"
  type        = bool
  default     = false
}

variable "audit_log_keep_days" {
  description = "Specifies the number of days for storing audit logs. The value ranges from 7 to 732"
  type        = number
  default     = 7
}

variable "audit_log_scope" {
  description = <<-EOF
    Specifies the audit scope. If this parameter is left blank or set to 'all', all audit log policies are enabled.
    You can enter the database or collection name. Use commas (,) to separate multiple databases or collections.
    Maximum 1024 characters.
  EOF
  type        = string
  default     = null
}

variable "audit_log_types" {
  description = "Specifies the audit type. Valid values: auth, insert, delete, update, query, command"
  type        = list(string)
  default     = null
}

variable "audit_log_reserve_auditlogs" {
  description = <<-EOF
    Specifies whether the historical audit logs are retained when SQL audit is disabled.
    true (default): indicates that historical audit logs are retained when SQL audit is disabled.
    false: indicates that existing historical audit logs are deleted when SQL audit is disabled.
  EOF
  type        = string
  default     = null
}

################################################################################
# Timeouts
################################################################################

variable "timeouts" {
  description = "Terraform resource management timeouts"
  type        = map(string)
  default     = {}
}

