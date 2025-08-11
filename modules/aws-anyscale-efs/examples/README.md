# Examples for using the aws-anyscale-efs module

These examples demonstrate how to use the `aws-anyscale-efs` module to create AWS Elastic File System (EFS) resources for Anyscale applications and workloads. EFS provides scalable, cloud-based file storage that is required for Anyscale Workspaces.

## Overview

The `aws-anyscale-efs` module creates AWS Elastic File System resources that provide scalable, shared file storage for applications and workloads. EFS is designed for scalable performance and is secure & compliant with common regulatory standards. This module is required for Anyscale Workspaces functionality.

**Note**: EFS deployment typically takes 5-10 minutes to complete, depending on the configuration and number of mount targets.

## Examples Included

### Default Configuration (`all_defaults`)
This example demonstrates the minimal configuration required to create an EFS file system:
- Creates an EFS file system with default settings
- Uses general purpose performance mode
- Uses bursting throughput mode
- Enables encryption by default
- Creates mount targets in the default VPC subnets
- Enables backup policy with default settings
- Transitions files to Infrequent Access after 60 days

### Kitchen Sink Configuration (`kitchen_sink`)
This example demonstrates a comprehensive EFS setup with all available options:
- Creates a VPC with both public and private subnets
- Creates security groups with self-referencing ingress rules
- Creates an EFS file system with custom configuration:
  - Custom name (`tftest-kitchen_sink`)
  - MaxIO performance mode for high throughput
  - Provisioned throughput mode with 256 MiB/s
  - Custom lifecycle policies (transition to IA after 7 days)
  - Custom file system policy with client mount permissions
  - Mount targets in private subnets with security groups
  - Multiple access points (POSIX and root directory)
  - Backup policy enabled
  - Custom tags and encryption settings
- Includes all optional features and customizations

### No Resources Configuration (`test_no_resources`)
This example demonstrates how to disable the module entirely:
- Sets `module_enabled = false`
- No EFS resources are created
- Useful for testing or when EFS is not required

## Important Notes

- EFS deployment takes 5-10 minutes to complete
- This module is required for Anyscale Workspaces functionality
- EFS policies to enforce TLS traffic are not currently supported for Anyscale Workspaces
- The `attach_policy` variable defaults to `false` to avoid TLS policy conflicts
- Ensure your VPC and security groups are properly configured for EFS access
- Consider using private subnets for production deployments
- Review and adjust the lifecycle policies based on your storage requirements

## Dependencies

This module depends on:
- `aws-anyscale-vpc` module for VPC resources (optional, can use existing VPC)
- `aws-anyscale-securitygroups` module for security group configuration (optional)
- AWS provider with appropriate permissions for EFS resources
