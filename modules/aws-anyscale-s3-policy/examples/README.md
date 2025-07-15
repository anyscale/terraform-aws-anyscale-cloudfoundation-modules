# Examples for using the aws-anyscale-s3-policy module

These examples demonstrate how to use the `aws-anyscale-s3-policy` module to create AWS S3 bucket policies for Anyscale deployments. S3 bucket policies control access to S3 buckets and ensure secure, compliant access patterns for Anyscale services.

## Overview

The `aws-anyscale-s3-policy` module creates AWS S3 bucket policies with configurable features including:
- Predefined policy template with SSL enforcement
- Anyscale-specific access permissions for control plane and data plane roles
- Custom policy overrides for additional requirements
- Secure transport enforcement (HTTPS only)
- Comprehensive S3 permissions for Anyscale operations

This module is essential for Anyscale deployments as it ensures proper access control and security compliance for S3 buckets used by Anyscale services.

## Examples Included

### Default Configuration (`all_defaults`)
This example demonstrates the minimal configuration required to create an S3 bucket policy:
- Creates an S3 bucket using the `aws-anyscale-s3` module
- Creates IAM roles using the `aws-anyscale-iam` module
- Applies the predefined S3 bucket policy with:
  - SSL enforcement (denies non-HTTPS requests)
  - Full S3 permissions for Anyscale control plane and data plane roles
  - Access to bucket operations and multipart uploads
- Uses default policy template without custom overrides

### Kitchen Sink Configuration (`kitchen_sink`)
This example demonstrates a comprehensive S3 policy setup with custom overrides:
- Creates an S3 bucket using the `aws-anyscale-s3` module
- Creates IAM roles using the `aws-anyscale-iam` module
- Applies a custom S3 bucket policy that:
  - Includes the predefined policy as the base
  - Adds custom policy statements for specific use cases
  - Demonstrates policy override capabilities
  - Shows how to add additional permissions or restrictions
- Custom policy includes:
  - Additional PutObject permissions with specific conditions
  - Deny statements for specific objects
  - Custom principal assignments

### No Resources Configuration (`test_no_resources`)
This example demonstrates how to disable the module entirely:
- Sets `module_enabled = false`
- No S3 bucket policy resources are created
- Useful for testing or when S3 policies are not required

## Important Notes

- S3 bucket policies are applied at the bucket level and affect all objects
- The predefined policy enforces HTTPS-only access for security
- Custom policy overrides completely replace the predefined policy
- Ensure IAM roles have appropriate permissions before applying bucket policies
- Policy changes may take time to propagate across AWS services
- Test custom policies thoroughly in non-production environments

## Dependencies

This module depends on:
- AWS provider with appropriate permissions for S3 and IAM resources
- Terraform >= 1.0
- `aws-anyscale-s3` module for bucket creation
- `aws-anyscale-iam` module for role creation

The module is typically used as part of the larger Anyscale Cloud Foundation deployment.
