## 0.25.0 (Released)
FEATURES:
- Updates to least priveledged IAM policy for the Control Plane Role
  - Add permissions for new dependency tracking functionality on Anyscale Workspaces

BUG FIXES:

BREAKING CHANGES:

NOTES:

## 0.24.0 (Released)
FEATURES:
- Updates to least priveledged IAM policy for the Control Plane Role
  - When passing in a Cloud ID, additional IAM conditions can be applied for EBS Volumes and IAM Instance Profile associations based on the Cloud ID tag.

BUG FIXES:

BREAKING CHANGES:

NOTES:

## 0.22.2 (Released)
FEATURES:

BUG FIXES:

BREAKING CHANGES:

NOTES:
- General README and Variable cleanup

## 0.22.1 (Released)
FEATURES:
- Add initial support for Anyscale on EKS.

BUG FIXES:
- Update EKS Node Group autoscaling template vesion assignment so that Terraform doesn't detect changes on every apply.

BREAKING CHANGES:

NOTES:

## 0.22.0 (Released)
FEATURES:
- Add initial support for Anyscale on EKS.

BUG FIXES:

BREAKING CHANGES:

NOTES:

## 0.21.1 (Released)
FEATURES:

BUG FIXES:

BREAKING CHANGES:

NOTES:
- Documentation update for KMS example

## 0.21.0 (Released)
FEATURES:
- Add IAM policy update for Anyscale Services change to add HTTP headers for versions.

BUG FIXES:

BREAKING CHANGES:

NOTES:

## 0.20.0 (Released)
FEATURES:
- Proper KMS support for EFS and S3 buckets

BUG FIXES:
- VPC Subnet name changes to remove deprecated double lookup call.

BREAKING CHANGES:

NOTES:
- README updates
- Add functional-verify to example outputs
- Upgrade pre-commit from tfsec (deprecated) to trivy

## 0.19.4 (Released)
FEATURES:

BUG FIXES:

BREAKING CHANGES:

NOTES:
- README updates

## 0.19.3 (Released)
FEATURES:
- S3 bucket CORS updates to support additional Anyscale UI functionality

BUG FIXES:

BREAKING CHANGES:

NOTES:

## 0.19.2 (Released)
FEATURES:

BUG FIXES:

BREAKING CHANGES:

NOTES:
- Removed unused Go tests

## 0.19.1 (Released)
FEATURES:

BUG FIXES:
- Fix issue with IAM policy creation when passing in an existing S3 Bucket.
- Fix Existing S3 example - Output update to use variable for s3 bucket id.

BREAKING CHANGES:

NOTES:

## 0.19.0 (Released)
FEATURES:
- Updates to EFS outputs to include IPs
- Updates to VPC outputs to include Subnets to AZ map

BUG FIXES:

BREAKING CHANGES:

NOTES:

## 0.18.3 (Released)
FEATURES:

BUG FIXES:

BREAKING CHANGES:

NOTES:
- Updates to pre-commit and tflint config files
- Updates to Pull request template
- Updates to example outputs for the registration command, making it more readable.

## 0.18.2 (Released)
FEATURES:

BUG FIXES:
- Force AWS Provider to 5.16 in unit test. 5.17 has a bug with deleting S3 content.

BREAKING CHANGES:

NOTES:

## 0.18.1 (Released)
FEATURES:

BUG FIXES:
- IAM Policy fix for Cloudwatch Log/Metrics integration.

BREAKING CHANGES:

NOTES:

## 0.18.0 (Released)
FEATURES:
- (Optional) MemoryDB Redis Cluster - this optional submodule creates a MemoryDB Redis Cluster for Anyscale Production Services. There are addditional updates to the VPC Submodule to optionaly create new VPC Subnets for the MemoryDB resource. The MemoryDB functionality provides [head node fault tolerance](https://docs.anyscale.com/productionize/services/head-node-fault-tolerance).

BUG FIXES:
- Fixed an error with the VPC name when using the `common_prefix` variable.

OTHER:
- Pre-Commit Updates
- Tests with latest Terraform and AWS provider

BREAKING CHANGES:

## 0.17.0 (Released)
FEATURES:
- (Optional) IAM policy for Anyscale Clusters to support reading Secrets Manager - this enables Bring Your Own Docker integrations where the docker host requires a username and password.

BUG FIXES:
- General cleanup of IAM Submodule including bugfix for custom IAM policy integrations.

OTHER:
- E2E test of Terraform with Cloud Register and Functional Verification script added. Not integrated with Github yet.
- Tested with latest Terraform and Terraform AWS Provider
- Pre-Commit Updates including latest checkov

BREAKING CHANGES:

## 0.16.0 (Released)
FEATURES:
- Additional root-module variable to allow adding a list of IAM Policy ARNs to the IAM Cluster Role

BUG FIXES:


BREAKING CHANGES:

## 0.15.3 (Released)
FEATURES:

BUG FIXES:
- Fix repetive executions removing assume rule condition when anyscale_cloud_id was null or ""

BREAKING CHANGES:


## 0.15.2 (Released)
FEATURES:

BUG FIXES:

BREAKING CHANGES:

NOTES:
- New example added for existing S3 bucket


## 0.15.1 (Released)
FEATURES:

BUG FIXES:

BREAKING CHANGES:

NOTES:
- Cleaned up the descriptions of the root module's variables.tf file to make it easier to read and understand.


## 0.15.0 (Released)
FEATURES:
- New IAM policy to allow writing AWS Cloudwatch logs and metrics. This is an optional policy controlled via variable. See the [readme.md](./README.md) for more information and the Anyscale Docs for [Cloudwatch logging](https://docs.anyscale.com/integrations/monitoring).

BUG FIXES:

BREAKING CHANGES:

NOTES:

## 0.14.3 (Released)
FEATURES:

BUG FIXES:
- Incremental updates to IAM permissions to allow modifications to ALB resources after creation for Anyscale Services.

BREAKING CHANGES:

NOTES:

## 0.14.2 (Released)
FEATURES:

BUG FIXES:

BREAKING CHANGES:

NOTES:
- Documentation and example updates

## 0.14.1 (Released)
FEATURES:

BUG FIXES:

BREAKING CHANGES:

NOTES:
Updated the create-release file to include additional tags for point releases.

## 0.14.0 (Released)
FEATURES:

BUG FIXES:

BREAKING CHANGES:

NOTES:
Unit tests updated. Should have been 0.13.1.
This was a new minor release instead of a point release as the tag was not in the create-release file.

## 0.13.0 (Released)
FEATURES:
- Update to latest AWS Provider (v5.x)
- IAM SubModule - Allow alternative trusted role arn for automated testing

## 0.12.0 (Unreleased)
FEATURES:

BUG FIXES:

BREAKING CHANGES:

NOTES:
Forced new deploy as Terraform Registry wasn't picking this release up correctly.

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
