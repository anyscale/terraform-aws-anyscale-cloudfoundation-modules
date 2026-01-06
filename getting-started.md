# A Beginner's Guide to Using Terraform with Amazon Web Services and Anyscale AWS Cloudfoundation Module

## Introduction
In this guide, we will walk through setting up and using Terraform with the Amazon Web Services from your local laptop. We will be using the Anyscale AWS Cloudfoundation module found in the Terraform Registry. We will create a basic example based on the anyscale-v2-commonname example from the registry.

The anyscale-v2-commonname example builds the following AWS resources:
- S3 Bucket - Standard
- IAM Roles for the control and data planes
- VPC with publicly routed subnets (no private subnets)
- VPC Security Groups

It does not create:
- VPC with private subnets or any firewalls
- EFS for optional NFS mounted cluster storage
- MemoryDB for optional Anyscale service head node high availability

## Prerequisites
1. An AWS account
2. Terraform installed on your local laptop (version 1.0.0 or later)
   1. You can install terraform on a mac with `brew` via `brew install terraform`. Other [install options](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli) are available.
3. AWS CLI (awscli) installed on your local laptop
   1. You can install the aws cli with `brew` via `brew install awscli`. Other [install options](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) are available.
4. Git CLI installed on your local laptop.
5. Anyscale CLI installed on your local laptop needs to be 0.26.40 or newer. You can install/upgrade your cli with: `pip install anyscale --upgrade`
6. Basic understanding of Terraform and Infrastructure as Code

#### Required AWS user permissions
To successfully run the Terraform commands in this guide, your AWS user must have appropriate permissions. The user should have the following policy:
- **PowerUserAccess**: The user should have Power User Access or have a custom policy with equivalent permissions. This policy allows the user to create and manage resources in the AWS account.

**Note**: If you're using a Service Account to run the Terraform commands, make sure it has the required permissions mentioned above. You can follow the same steps to assign roles to the Service Account.

## Steps

### 1. Authenticate with AWS:
Before using the Amazon Web Services with Terraform, you need to authenticate. Run the following command to authenticate with your AWS account:
```
aws configure
```

### 2. Clone the Anyscale examples repository:
Clone the Anyscale examples repository to your local laptop to access the example configuration files:
```
git clone https://github.com/anyscale/terraform-aws-anyscale-cloudfoundation-modules
```

### 3. Navigate to the example directory:
Navigate to the example directory (anyscale-v2-commonname) within the cloned repository:
```
cd terraform-aws-anyscale-cloudfoundation-modules/examples/anyscale-v2-commonname
```

### 4. Initialize Terraform:
Before running Terraform commands, you need to initialize the working directory. Run the following command to initialize Terraform with the AWS provider:
```
terraform init
```

### 5. Modify the `main.tf` file:
In the `main.tf` file, modify the configuration to fit your needs. You may need to update the variables for you're needs.
Common variables to update are listed below. Additionally, customize the resources created by the Anyscale module.
You can also update the region that resources are created in.

#### Common Variables to modify
- `anyscale_vpc_cidr_block` - This is the network size that you'd like to create on AWS.
- `anyscale_vpc_public_subnets` - These are the public subnets that will be created in the VPC.
- `customer_ingress_cidr_ranges` - This is the ingress CIDR range for the security group to allow traffic from.
- `anyscale_external_id` - This variable allows you to specify a custom external ID for locking down the Control Plane IAM role. If used, it must start with your Anyscale organization ID.
- `anyscale_vpc_private_subnets` - These are private subnets that will be created in the VPC. For a full example using private-only networking, check out the anyscale-v2-privatesubnets example.

### 6. Create a `terraform.tfvars` file:
Create a `terraform.tfvars` file in the example directory to store your project-specific variables. Update the variables according to your AWS setup. For example:
```
aws_region           = "<aws_region_you_want_to_use>"
common_prefix        = "anyscale-tf-"
anyscale_external_id = "<anyscale_org_id>-<custom_external_id>"

customer_ingress_cidr_ranges = "0.0.0.0/0"
```

### 7. Validate the configuration:
Before creating resources, you can validate your configuration using the following command:
```
terraform validate
```

### 8. Plan the changes:
Check the planned changes to your infrastructure by running:
```
terraform plan -var-file="terraform.tfvars"
```

### 9. Apply the changes:
If everything looks good, apply the changes to create the resources:
```
terraform apply -var-file="terraform.tfvars"
```
Type 'yes' when prompted to confirm the resource creation.

### 10. Verify the created resources:
Check your AWS Console to verify that the resources have been created successfully.

### 11. Use the outputs to register Anyscale Cloud:
With the outputs from Terraform, you can use the `anyscale cloud register`
command example to register an Anyscale Cloud. You will want to make
sure to edit the name of the cloud.

Example Cloud Register command for AWS:
```
anyscale cloud register --provider aws  \
--name aws-anyscale-tf-test-1 \
--region us-east-2
--vpc-id vpc-123456789012 \
--subnet-ids subnet-1234567890abcdef,subnet-23456778901abcdef,subnet3456789012abcdef \
--efs-id efs-12354790  \
--anyscale-iam-role-id arn:aws:iam::123456789012:role/anyscale-tf-12345789abcd-crossacct-iam-role \
--instance-iam-role-id arn:aws:iam::123456789012:role/anyscale-tf-12345789abcd-cluster-node-role \
--security-group-ids anyscale-tf-test-1-cluster@gcp-register-cloud-1.iam.gserviceaccount.com \
--s3-bucket-id anyscale-tf-test-1-fw  \
--external-id org_1234567890abcdef-example_id
```
### 12. Re-run the Terraform Module with Anyscale cloud ID (optional):
To enable consistent tagging for billing or to support tag-based conditions in the
IAM policies for the control plane, set the `anyscale_cloud_id` variable and re-run the Terraform modules.
This will:
- Apply consistent tags to all newly created resources
- Add tag-based conditions and restrictions to IAM policies

### Clean up resources (optional):
Once you are done, you can destroy the resources created by Terraform:
```
terraform destroy -var-file="terraform.tfvars"
```
Type 'yes' when prompted to confirm the resource destruction.

## Decisions & Preferences

Before deploying the Anyscale platform, certain decisions need to be made with regards to the infrasture preferences and design. The following section outlines the major ones. Going over these before deployment can speed up the process:

### 1. Networking Architecture
- Direct Networking (simple): Public subnets, public IPs, internet-facing
- Customer Defined Networking (enterprise): Private subnets, NAT gateways, more secure
- **Decision:** Most enterprises choose Customer Defined with --private-network flag

### 2. VPC Strategy
- New VPC: Create dedicated (recommended /16 CIDR like 10.0.0.0/16)
- Existing VPC: Integrate with current network infrastructure
- **Decision:** Do you have existing VPC requirements or create new?

### 3. Subnet Design
- Number: Minimum 2, recommended 3+ for multi-AZ
- Size: /22 CIDR (1,024 IPs each) recommended
- Type: Public only vs Private with NAT
- **Decision:** How many subnets and in which availability zones?

### 4. Access Control
- Ingress CIDR ranges: Which IPs can access clusters (office, VPN, CI/CD)
- SSH access: Enable port 22 or use SSM only?
- Machine pools: Up to 2 CIDR ranges maximum (AWS limit)
- **Decision:** Define your security_group_ingress_allow_access_from_cidr_range

### 5. IAM Configuration
- External ID: Use format org_id-custom_string for enhanced security
- CloudWatch logs: Enable cluster logging to CloudWatch?
- Custom policies: Additional permissions for Secrets Manager, RDS, etc.?
- **Decision:** What additional AWS services will clusters need?

### 6. Storage Options
S3 Bucket:
- New dedicated vs existing bucket
- Encryption: AES256 (default) or KMS
- Lifecycle policies for cost optimization
- **Decision:** KMS encryption required by compliance?

EFS (Optional):
- Shared cluster storage
- **Decision:** Set create_efs_resources true/false

MemoryDB (Optional):
- Head node fault tolerance for Services
- **Decision:** Set create_memorydb_resources true/false (recommend true for production)

### 7. Region & Availability
- Region: Which AWS region? (no China/GovCloud)
- Multi-AZ: Distribute across 2-3 availability zones
- VPC Endpoints: Create S3 endpoint for cost/performance?
- **Decision:** Primary region and DR strategy?

### 8. Resource Naming
- Common naming: Use use_common_name=true for consistency
- Prefix: Define common_prefix (e.g., "company-anyscale-")
- Tags: Cost center, environment, owner tags
- **Decision:** Naming convention and tagging strategy

### 9. Environment Strategy
- Separation: Separate clouds per environment or shared?
- Deployment env: Set anyscale_deploy_env (dev/staging/prod)
- **Decision:** How many Anyscale clouds needed?

### 10. Compliance & Security
- AWS Account: Dedicated or shared account?
- KMS keys: Customer-managed keys required?
- Audit logging: CloudWatch logs enabled?
- **Decision:** What are your compliance requirements?


## Conclusion
In this guide, we have covered how to set up and use Terraform with Amazon Web Services from a local laptop. We used the Anyscale AWS cloudfoundation module to create resources based on the anyscale-v2-commonname example. Now you can create and manage your infrastructure on AWS using Terraform and the Anyscale module.
