variable "region" {
  description = "The region in which to create the DDS instance"
  type        = string
  default     = null
}

variable "name" {
  description = "The name of the DDS instance"
  type        = string
  default     = null
}

variable "use_name_prefix" {
  description = "Whether to use name as a prefix. If true, name will be set to null and Terraform will generate a unique name"
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
  description = "Specifies the VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Specifies the subnet Network ID"
  type        = string
}

variable "security_group_id" {
  description = "Specifies the security group ID of the DDS instance"
  type        = string
}

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
  description = "Specifies the storage engine. For version 4.0: wiredTiger. For versions 4.2, 4.4, 5.0: rocksDB"
  type        = string
  default     = null
}

variable "password" {
  description = "Specifies the Administrator password of the database instance"
  type        = string
  sensitive   = true
  default     = null
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

variable "configuration_id" {
  description = "Specifies the ID of the parameter template"
  type        = string
  default     = null
}

variable "configuration_type" {
  description = "Specifies the node type for configuration. Valid values: mongos, shard, config (for Sharding), replica (for ReplicaSet)"
  type        = string
  default     = null
}

variable "backup_strategy" {
  description = <<-EOF
    Backup strategy configuration.
    
    Example:
    {
      start_time = "08:00-09:00"
      keep_days  = 8
      period     = "1,3,5"  # Optional, backup cycle (days of week)
    }
  EOF
  type = object({
    start_time = string
    keep_days  = number
    period     = optional(string)
  })
  default = null
}

variable "maintain_begin" {
  description = "Specifies begin time of the maintenance window. Format: hh:mm in UTC+0"
  type        = string
  default     = null
}

variable "maintain_end" {
  description = "Specifies end time of the maintenance window. Format: hh:mm in UTC+0"
  type        = string
  default     = null
}

variable "replica_set_name" {
  description = "Specifies the name of the replica set in the connection address. Must be 3-128 characters, start with a letter. Default is 'replica'"
  type        = string
  default     = null
}

variable "client_network_ranges" {
  description = "Specifies the CIDR block where the client is located. Only for ReplicaSet mode"
  type        = list(string)
  default     = []
}

variable "ssl" {
  description = "Specifies whether to enable or disable SSL. Defaults to true"
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
  description = "Specifies the start time of the balancing activity time window. Format: HH:MM. Required with balancer_active_end. Only for Sharding mode"
  type        = string
  default     = null
}

variable "balancer_active_end" {
  description = "Specifies the end time of the balancing activity time window. Format: HH:MM. Required with balancer_active_begin. Only for Sharding mode"
  type        = string
  default     = null
}

variable "enterprise_project_id" {
  description = "Specifies the enterprise project id of the DDS instance"
  type        = string
  default     = null
}

variable "description" {
  description = "Specifies the description of the DDS instance"
  type        = string
  default     = null
}

variable "charging_mode" {
  description = "Specifies the charging mode. Valid values: 'prePaid' (yearly/monthly), 'postPaid' (pay-per-use, default)"
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
  description = "Specifies whether auto-renew is enabled. Valid values: 'true', 'false'"
  type        = string
  default     = null
}

variable "tags" {
  description = "The key/value pairs to associate with the DDS instance"
  type        = map(string)
  default     = {}
}

variable "timeouts" {
  description = "Terraform resource management timeouts"
  type        = map(string)
  default     = {}
}

