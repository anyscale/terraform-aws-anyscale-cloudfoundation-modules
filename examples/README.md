# Examples for creating Anyscale related resources

These examples are for learning purposes and should be modified for your particular production use cases.

### anyscale-v2-commonname
This builds the foundational Anyscale Cloud Resources with a Common Name including:
  - IAM Roles
  - S3 Bucket
  - VPC with publicly routed subnets (no internal)
  - VPC Security Groups allowing public from Anyscale
  - EFS

### anyscale-v2-existing-s3
This builds the resources required to run Anyscale, but requires an Existing S3 bucket:
  - IAM Roles
  - VPC with publicly routed subnets
  - VPC Security Groups
  - S3 Policy on an existing S3 Bucket

### anysale-v2-existing-vpc
This builds foundational Anyscale Cloud Resources but expects an existing VPC. It creates:
  - IAM Roles
  - S3 Bucket
  - VPC Security Groups allowing public from Anyscale
  - EFS

### anyscale-v2-kitchensink
This uses as many non-contradicting variables as possible to create the resources needed for an Anyscale Cloud. It creates:
  - IAM Roles
  - S3 Bucket
  - VPC
  - VPC Security Groups
  - EFS
  - MemoryDB for HA Head nodes

### anyscale-v2-kms
This example creates and uses a KMS key to encrypt both S3 and EFS. It creates:
  - KMS Key
  - KMS Key Policy
  - IAM Roles
  - S3 Bucket encrypted with KMS
  - VPC
  - VPC Security Groups
  - EFS encrypted with KMS

### anyscale-v2-privatesubnets
This example creates a private networking solution for Anyscale. It requires a VPN or some other connectivity to manage end user traffic to the Anyscale Clusters. It creates:
  - IAM Roles
  - S3 Bucket
  - VPC with a Public Internet Gateway, Private Subnets with NAT Gateways
  - VPC Security Groups allowing only internal traffic inbound to the Anyscale Clusters
  - EFS


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
