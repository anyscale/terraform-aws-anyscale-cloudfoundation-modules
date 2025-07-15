# Examples for using the aws-anyscale-vpc module

These examples demonstrate how to use the `aws-anyscale-vpc` module to create AWS VPC resources for Anyscale deployments. VPCs provide the networking foundation for Anyscale services and ensure secure, isolated network environments.

## Overview

The `aws-anyscale-vpc` module creates AWS VPC resources with configurable features including:
- VPC creation with custom CIDR blocks and IPAM support
- Public and private subnets across multiple availability zones
- Internet Gateway for public subnet internet access
- NAT Gateway for private subnet internet access
- VPC Gateway Endpoints for AWS services (S3, DynamoDB)
- VPC Flow Logs for network monitoring and security
- Route tables and subnet associations
- Comprehensive tagging and naming options

This module is essential for Anyscale deployments as it provides the networking infrastructure needed for secure communication between Anyscale services and external resources.

## Examples Included

### Default Configuration (`all_defaults`)
This example demonstrates the minimal configuration required to create a VPC:
- Creates a VPC with a custom CIDR block (172.20.0.0/16)
- Uses default settings for all optional parameters
- No subnets are created by default
- Uses default naming and tagging conventions
- Demonstrates the most basic VPC setup

### Minimum Anyscale VPC Requirements (`minimum_anyscale_vpc_requirements`)
This example demonstrates the minimum VPC configuration needed for Anyscale:
- Creates a VPC with custom name and CIDR block (172.21.0.0/16)
- Creates public subnets in two availability zones
- Enables internet access for Anyscale services
- Shows the minimal configuration required for Anyscale deployment
- Demonstrates public-only subnet architecture

### Public/Private VPC Configuration (`public_private_vpc`)
This example demonstrates a VPC with both public and private subnets:
- Creates a VPC with custom name and CIDR block (172.22.0.0/16)
- Creates public subnets for internet-facing resources
- Creates private subnets for internal resources
- Enables NAT Gateway for private subnet internet access
- Shows a typical production-ready VPC architecture

### Existing VPC with New Subnets (`existing_vpc_new_subnets`)
This example demonstrates how to add subnets to an existing VPC:
- Uses an existing VPC ID (vpc-086408b268f481027)
- Creates new private subnets in the existing VPC
- Uses existing route tables for subnet associations
- Skips creation of Internet Gateway and NAT Gateway
- Shows how to extend existing VPC infrastructure

### Existing VPC with Endpoints (`existing_vpc_create_endpoints`)
This example demonstrates how to add VPC endpoints to an existing VPC:
- Uses an existing VPC ID (vpc-01e570eea1c7258ae)
- Creates VPC Gateway Endpoints for AWS services
- Uses existing route tables for endpoint associations
- Skips creation of other VPC resources
- Shows how to add AWS service connectivity to existing VPCs

### Kitchen Sink Configuration (`kitchen_sink`)
This example demonstrates a comprehensive VPC setup with all available options:
- Creates a VPC with custom name and CIDR block (172.23.0.0/16)
- Creates public and private subnets across three availability zones
- Configures custom subnet names and suffixes
- Enables VPC Flow Logs with CloudWatch integration
- Creates VPC Gateway Endpoints with custom policies
- Demonstrates advanced VPC features and configurations
- Shows production-ready VPC with monitoring and security features

### No Resources Configuration (`test_no_resources`)
This example demonstrates how to disable the module entirely:
- Sets `module_enabled = false`
- No VPC resources are created
- Useful for testing or when VPC is not required

## Dependencies

This module depends on:
- AWS provider with appropriate permissions for VPC, EC2, and IAM resources
- Terraform >= 1.0
- Time provider >= 0.9 (for resource creation delays)

The module can be used standalone but is typically used as part of the larger Anyscale Cloud Foundation deployment.
