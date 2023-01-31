# Examples for creating Anyscale related resources

These examples are for learning purposes.

### anyscale-v1-all-defaults
This builds foundational Anyscale Cloud Resources with the AWS Cloud Provider. It creates the resources for a v1 stack including:
  - IAM Roles
  - S3 Bucket
  - VPC with publicly routed subnets (no internal)
  - VPC Security Groups allowing public from Anyscale
  - EFS

### anysale-v1-existing-vpc
This builds foundational Anyscale Cloud Resources but expects an existing VPC. It creates the resources for a v1 stack including:
  - IAM Roles
  - S3 Bucket
  - VPC Security Groups allowing public from Anyscale
  - EFS

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
