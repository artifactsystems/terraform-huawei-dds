# HuaweiCloud DDS Terraform Module

Terraform module which creates DDS (Document Database Service) instances on HuaweiCloud. DDS is a fully managed MongoDB-compatible database service.

## Usage

### ReplicaSet Mode

```hcl
module "mongodb" {
  source = "github.com/artifactsystems/terraform-huawei-dds?ref=v1.1.0"

  identifier = "my-mongodb"

  mode              = "ReplicaSet"
  availability_zone = "tr-west-1a"
  vpc_id            = "vpc-xxxxx"
  subnet_id         = "subnet-xxxxx"
  security_group_id = "sg-xxxxx"

  datastore_version        = "4.0"
  datastore_storage_engine = "wiredTiger"

  password = "YourSecurePassword@123"

  flavors = [
    {
      type      = "replica"
      num       = 3
      storage   = "ULTRAHIGH"
      size      = 30
      spec_code = "dds.mongodb.s6.medium.4.repset"
    }
  ]

  backup_strategy = {
    start_time = "08:00-09:00"
    keep_days  = 7
    period     = "1,2,3,4,5,6,7"
  }

  maintenance_window = "02:00-03:00"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### Sharding Mode

```hcl
module "mongodb_cluster" {
  source = "github.com/artifactsystems/terraform-huawei-dds?ref=v1.1.0"

  identifier = "my-mongodb-cluster"

  mode              = "Sharding"
  availability_zone = "tr-west-1a"
  vpc_id            = "vpc-xxxxx"
  subnet_id         = "subnet-xxxxx"
  security_group_id = "sg-xxxxx"

  datastore_version        = "4.0"
  datastore_storage_engine = "wiredTiger"

  password = "YourSecurePassword@123"

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

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

## Features

This module supports the following DDS features:

- ✅ **Multiple Deployment Modes**: ReplicaSet and Sharding cluster configurations
- ✅ **MongoDB Versions**: Support for versions 4.0, 4.2, 4.4, and 5.0
- ✅ **Storage Engines**: wiredTiger (4.0) and rocksDB (4.2, 4.4, 5.0)
- ✅ **Automated Backups**: Configurable backup strategy with retention periods
- ✅ **Maintenance Windows**: Scheduled maintenance windows for updates
- ✅ **SSL/TLS Encryption**: Enable/disable SSL for secure connections
- ✅ **Disk Encryption**: Support for KMS disk encryption
- ✅ **High Availability**: Multi-node configurations for fault tolerance
- ✅ **Scalability**: Flexible flavor configurations for different workload requirements
- ✅ **Monitoring**: Second-level monitoring and slow log desensitization
- ✅ **Load Balancing**: Balancer configuration for Sharding mode
- ✅ **Billing Options**: Prepaid (yearly/monthly) and postpaid (pay-per-use)
- ✅ **Enterprise Projects**: Integration with HuaweiCloud Enterprise Projects
- ✅ **Tag Management**: Comprehensive tagging support for all resources

## Examples

- [replica-set](./examples/replica-set) - ReplicaSet mode with 3-node configuration
- [sharding](./examples/sharding) - Sharding cluster with mongos, shard, and config nodes

## Deployment Modes

### ReplicaSet Mode

ReplicaSet mode provides high availability with automatic failover. It supports 3, 5, or 7 replica nodes.

**Flavor Configuration:**
- `type`: Must be `"replica"`
- `num`: Number of replica nodes (3, 5, or 7)
- `spec_code`: Instance specification code (e.g., `"dds.mongodb.s6.medium.4.repset"`)
- `storage`: Storage type (e.g., `"ULTRAHIGH"`)
- `size`: Storage size in GB

**Example:**
```hcl
flavors = [
  {
    type      = "replica"
    num       = 3
    storage   = "ULTRAHIGH"
    size      = 30
    spec_code = "dds.mongodb.s6.medium.4.repset"
  }
]
```

### Sharding Mode

Sharding mode provides horizontal scaling for large datasets. It consists of mongos (router), shard (data), and config (metadata) nodes.

**Flavor Configuration:**

**Mongos Nodes:**
- `type`: Must be `"mongos"`
- `num`: Number of mongos nodes (2-16)
- `spec_code`: Instance specification code (e.g., `"dds.mongodb.s6.medium.4.mongos"`)
- `storage` and `size`: Not applicable for mongos

**Shard Nodes:**
- `type`: Must be `"shard"`
- `num`: Number of shard nodes (2-16)
- `spec_code`: Instance specification code (e.g., `"dds.mongodb.s6.medium.4.shard"`)
- `storage`: Storage type (e.g., `"ULTRAHIGH"`)
- `size`: Storage size in GB per shard

**Config Nodes:**
- `type`: Must be `"config"`
- `num`: Must be `1`
- `spec_code`: Instance specification code (e.g., `"dds.mongodb.s6.large.2.config"`)
- `storage`: Storage type (e.g., `"ULTRAHIGH"`)
- `size`: Storage size in GB

**Example:**
```hcl
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
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| huaweicloud | >= 1.56.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| identifier | The name of the DDS instance | `string` | n/a | yes |
| mode | Deployment mode: `ReplicaSet` or `Sharding` | `string` | n/a | yes |
| availability_zone | Availability zone for the instance | `string` | n/a | yes |
| vpc_id | VPC ID where the instance will be created | `string` | n/a | yes |
| subnet_id | Subnet ID where the instance will be created | `string` | n/a | yes |
| security_group_id | Security group ID to associate | `string` | n/a | yes |
| datastore_version | MongoDB version (4.0, 4.2, 4.4, 5.0) | `string` | n/a | yes |
| password | Administrator password (8-32 chars, 3+ character types) | `string` | n/a | yes |
| flavors | List of flavor configurations | `list(object)` | n/a | yes |

See [variables.tf](./variables.tf) for the complete list of available variables.

## Outputs

| Name | Description |
|------|-------------|
| dds_instance_id | The DDS instance ID |
| dds_instance_name | The DDS instance name |
| dds_instance_status | The DDS instance status |
| dds_instance_db_username | The DB Administrator name |
| dds_instance_port | The database port number |
| dds_instance_groups | The instance groups information |
| dds_instance_created_at | The create time |
| dds_instance_updated_at | The update time |
| dds_instance_time_zone | The time zone |

See [outputs.tf](./outputs.tf) for the complete list of available outputs.

## Contributing

Report issues/questions/feature requests in the [issues](https://github.com/artifactsystems/terraform-huawei-dds/issues/new) section.

Full contributing [guidelines are covered here](.github/CONTRIBUTING.md).
