# Examples for using the aws-anyscale-securitygroups module

These examples demonstrate how to use the `aws-anyscale-securitygroups` module to create AWS Security Groups for Anyscale deployments. Security Groups control network access to Anyscale resources and ensure secure communication between services.

## Overview

The `aws-anyscale-securitygroups` module creates AWS Security Groups with configurable features including:
- Main security group for Anyscale control plane and data plane resources
- Machine pool security group for worker nodes with specific port ranges
- Flexible ingress and egress rules with CIDR blocks, security groups, and self-references
- Predefined rule templates for common protocols (HTTP, HTTPS, SSH, NFS)
- Custom port ranges and protocol configurations
- Comprehensive tagging and naming options

This module is essential for Anyscale deployments as it provides the network security infrastructure needed for secure communication between Anyscale services and external resources.

## Examples Included

### Default Configuration (`all_defaults`)
This example demonstrates the minimal configuration required to create a security group:
- Creates a VPC using the `aws-anyscale-vpc` module for testing
- Creates a security group with default settings
- Configures HTTPS ingress from specified CIDR blocks
- Uses default self-referencing rules for internal communication
- Applies default egress rules for internet access
- Uses default naming and tagging conventions

### Anyscale Machine Pool Configuration (`anyscale_amp`)
This example demonstrates machine pool security group setup:
- Creates a VPC using the `aws-anyscale-vpc` module for testing
- Creates a security group with custom name prefix for machine pools
- Configures machine pool CIDR ranges for worker node access
- Sets up specific port ranges for Anyscale services (22 port ranges total)
- Demonstrates machine pool security group naming conventions
- Shows how to configure worker node network access

### Kitchen Sink Configuration (`kitchen_sink`)
This example demonstrates a comprehensive security group setup with all available options:
- Creates a VPC using the `aws-anyscale-vpc` module for testing
- Creates a security group with custom name and description
- Configures multiple ingress rule types:
  - CIDR-based rules for specific IP ranges
  - Custom port ranges with specific protocols
  - Rules from existing security groups
  - Self-referencing rules for internal communication
- Configures multiple egress rule types:
  - Self-referencing egress rules
  - CIDR-based egress rules
- Creates a machine pool security group with:
  - Custom naming and description
  - Multiple CIDR ranges for worker nodes
  - All predefined port ranges for Anyscale services
- Demonstrates complex rule combinations and security group relationships

### No Resources Configuration (`test_no_resources`)
This example demonstrates how to disable the module entirely:
- Sets `module_enabled = false`
- No security group resources are created
- Useful for testing or when security groups are not required

## Dependencies

This module depends on:
- AWS provider with appropriate permissions for VPC and Security Group resources
- Terraform >= 1.0
- `aws-anyscale-vpc` module for VPC creation (in examples)

The module can be used standalone but is typically used as part of the larger Anyscale Cloud Foundation deployment.
