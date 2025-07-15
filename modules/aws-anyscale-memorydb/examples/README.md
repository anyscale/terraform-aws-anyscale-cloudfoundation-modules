# Examples for using the aws-anyscale-memorydb module

These examples demonstrate how to use the `aws-anyscale-memorydb` module to create AWS MemoryDB resources for Anyscale Services HA (High Availability) deployments. MemoryDB is used to handle head node failures in production Anyscale environments.

## Overview

The `aws-anyscale-memorydb` module creates AWS MemoryDB for Redis resources that provide fast, in-memory database capabilities with fault tolerance through multi-AZ replication. This module is optional and should only be used for production Anyscale workloads that require high availability.

**Note**: Enabling this module will increase deployment time by 15-30 minutes due to the time required to provision MemoryDB resources.

## Examples Included

### Default Configuration (`all_defaults`)
This example demonstrates the minimal configuration required to create a MemoryDB cluster:
- Creates a VPC with public subnets
- Creates security groups with basic ingress rules
- Creates a MemoryDB cluster with default settings
- Uses the default Redis 7.0 engine version
- Uses the default `db.t4g.small` node type
- Creates 1 shard with 2 replicas per shard

### Kitchen Sink Configuration (`kitchen_sink`)
This example demonstrates a comprehensive MemoryDB setup with all available options:
- Creates a VPC with both public and private subnets
- Creates security groups with self-referencing ingress rules
- Creates a MemoryDB cluster with custom configuration:
  - Custom node type (`db.r6gd.xlarge`)
  - Custom port (6380)
  - 4 shards with 3 replicas per shard
  - Data tiering enabled
  - TLS encryption enabled
  - Custom maintenance and snapshot windows
  - Custom parameter group with Redis parameters
  - MemoryDB ACL with user access control
  - Custom MemoryDB users (admin and readonly)
  - Custom subnet group using private subnets
- Includes all optional features and customizations

### No Resources Configuration (`test_no_resources`)
This example demonstrates how to disable the module entirely:
- Sets `module_enabled = false`
- No MemoryDB resources are created
- Useful for testing or when MemoryDB is not required

## Important Notes

- MemoryDB deployment takes 15-30 minutes to complete
- This module is optional and only needed for production HA deployments
- Ensure your VPC and security groups are properly configured for MemoryDB access
- Consider using private subnets for production deployments
- Review and adjust the parameter group settings based on your application requirements

## Dependencies

This module depends on:
- `aws-anyscale-vpc` module for VPC resources
- `aws-anyscale-securitygroups` module for security group configuration
- AWS provider with appropriate permissions for MemoryDB resources
