# A Beginner's Guide to Using Terraform with Amazon Web Services and Anyscale AWS Cloudfoundation Module

## Introduction
In this guide, we will walk through setting up and using Terraform with the Amazon Web Services from your local laptop. We will be using the Anyscale AWS Cloudfoundation module found in the Terraform Registry. We will create a basic example based on the anyscale-v2-commonname example from the registry.

The anyscale-v2-commonname example builds the following AWS resources:
- S3 Bucket - Standard
- IAM Roles
- VPC with publicly routed subnets (no private subnets)
- VPC Security Groups
- EFS

## Prerequisites
1. An AWS account
2. Terraform installed on your local laptop (version 1.0.0 or later)
   1. You can install terraform on a mac with `brew` via `brew install terraform`. Other [install options](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli) are available.
3. AWS CLI (awscli) installed on your local laptop
   1. You can install the aws cli with `brew` via `brew install awscli`. Other [install options](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) are available.
4. Git CLI installed on your local laptop.
5. Anyscale CLI installed on your local laptop needs to be 0.5.104 or newer. You can install/upgrade your cli with: `pip install anyscale --upgrade`
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
- `anyscale_vpc_private_subnets` - These are private subnets that will be created in the VPC. For a full example using private-only networking, check out the anyscale-v2-privatesubnets example.

### 6. Create a `terraform.tfvars` file:
Create a `terraform.tfvars` file in the example directory to store your project-specific variables. Update the variables according to your AWS setup. For example:
```
aws_region        = "<aws_region_you_want_to_use>"
common_prefix     = "anyscale-tf-"
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
```

### 12. Recommended: Lock down AWS resources with Anyscale Cloud ID.
You can use the Cloud ID that was generated in the previous step as an additional parameter for the AWS Anyscale Terraform Cloudfoundation Modules.
This provides an extra layer of security for the cross account role - Anyscale sends the Cloud ID as part of the information sent during the assume-role process.
Using this additional variable, you can run multiple secure Anyscale Clouds in the same AWS account.

Update the `terraform.tfvars` file and add
```
anyscale_cloud_id` = "<your_anyscale_cloud_id>"
```
Where the Cloud ID is the ID that is returned by the Anyscale CLI when you registered it in the previous step - the Cloud ID should look like `cld_1234567890abcdefgh1235abcd`.

Then, re-run `terraform apply` - this will update only the cross account role.
To verify that this applied correctly, you can run: `anyscale cloud verify --id <cloud-id>` which will double check all permissions and configurations.

### 13. Clean up resources (optional):
Once you are done, you can destroy the resources created by Terraform:
```
terraform destroy -var-file="terraform.tfvars"
```
Type 'yes' when prompted to confirm the resource destruction.

## Conclusion
In this guide, we have covered how to set up and use Terraform with the Amazon Web Services from a local laptop. We used the Anyscale AWS Cloudfoundation module to create resources based on the anyscale-v2-commonname example. Now you can create and manage your infrastructure on AWS using Terraform and the Anyscale module.
