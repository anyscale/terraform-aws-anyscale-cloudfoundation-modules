## 0.11.1 (Released)
FEATURES:

BUG FIXES:
- Additional permission for Anyscale Services allowing modification of ELB.

BREAKING CHANGES:


## 0.11.0 (Released)
FEATURES:

BUG FIXES:
- Additional tightening of policies around Service Linked Role creation.

BREAKING CHANGES:

## 0.10.0 (Released)
FEATURES:

BUG FIXES:
- Additional security for Services v2 IAM policies. This resolves issues with brand new AWS accounts.

BREAKING CHANGES:
- Removed ELB Service Linked Role from Terraform. If your terraform modules created this role, and you apply this update, this will potentially remove the Service Linked Role for Elastic Load Balancing. The Cloudformation script that creates the Anyscale Services will recreate it. If the Service Linked Role is in use during an update, the terraform module may throw an error.

## 0.9.0 (Released)

FEATURES:
- Additional security for Services v2 IAM Policies
- Added outputs to Examples that builds Anyscale `cloud register` cli command.

BUG FIXES:
- Fixed S3 Kitchen Sink test

BREAKING CHANGES:

## 0.8.0 (Released)

FEATURES:
- Add export for Route Table IDs to the root module.

BUG FIXES:
- New S3 buckets no longer support canned ACLs out-of-the-box. This variable and configuration have been removed from the S3 sub-module.

BREAKING CHANGES:

## 0.7.0 (Released)

FEATURES:
- Add subnet-level tags to aws-anyscale-vpc module
- Add subnet-level tags to the root module

BUG FIXES:

BREAKING CHANGES:

## 0.6.1 (Released)

FEATURES:
- Documentation updates

BUG FIXES:

BREAKING CHANGES:

## 0.6.0 (Released)

FEATURES:
- Support for Anyscale Services v2 including IAM policy updates for Cross Account access role.

BUG FIXES:
- IAM policy fix for cross account access role when cloud id is provided.

BREAKING CHANGES:

## 0.5.2 (Released)

FEATURES:

BUG FIXES:
- EFS Security Policy was not properly built
- EFS Mounts were not being created in all regions

BREAKING CHANGES:

## 0.5.1 (Released)

FEATURES:
- Root README.md updates - Anyscale v2 has been tested

BUG FIXES:

BREAKING CHANGES:

## 0.5.0 (Released)

FEATURES:
- Add custom IAM parameters to Root Module
- Update unit tests for Anyscale v2
- Add parameter to the root module to control random length
- Add S3 parameters to the Root Module
- Cleanup code within the readme.md coming from variables.tf

BUG FIXES:
- VPC Endpoint bug fix

BREAKING CHANGES:

## 0.4.0 (Un-Released)

FEATURES:
- Bug fixes
- Examples for common name on Anyscale v2
- Root module Anyscale v2 TerraTest unit tests written

## 0.3.0 (Released)

FEATURES:
- Root Module updates to allow a common name across all resources.
- Examples for common name on Anyscale v2

BREAKING CHANGES:
- Rename general_prefix to common_prefix

## 0.2.2 (Un-Released)

FEATURES:
- Github actions testing and updates

## 0.2.1 (Un-Released)

FEATURES:
- Additional examples for Anyscale v2
- Github actions

## 0.2.0 (Released)

FEATURES:
- Allow Subnet Creation with existing VPC
- Allow VPC Endpoints creation with existing VPC
- v1 tftest updates
- v2 tftest initial commit

## 0.1.0 (Released)

Initial commit

FEATURES:
- EFS Submodule
- IAM Submodule
- S3 Submodule
- S3 Policy Submodule
- Security Groups Submodule
- VPC Submodule
