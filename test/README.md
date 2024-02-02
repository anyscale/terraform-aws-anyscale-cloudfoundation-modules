# aws-anyscale module (and sub-modules) unit tests

Requirements:
* Anyscale cli
* AWS CLI (& boto3) - for AWS Module testing
* GCloud CLI (& python libraries) - for GCP Module testing
* python-terraform

## Tests Breakdown

### anyscale-v2-e2e-private-test

This creates resources for a Private Anyscale Cloud including E2E testing. It includes:
  - VPC with private routed subnets
  - VPC Security group
  - S3 Bucket
  - S3 Bucket Policy
  - IAM Roles
  - EFS
It then registers an Anyscale Cloud and creates a Workspace before terminating it and destroying the cloud.

### anyscale-v2-e2e-public-test

This creates resources for a Public Anyscale Cloud including E2E testing. It includes:
  - VPC with public routed subnets
  - VPC Security group
  - S3 Bucket
  - S3 Bucket Policy
  - IAM Roles
  - EFS
  - MemoryDB for HA Services
It then registers an Anyscale Cloud and creates a Workspace and Service before terminating both and destroying the cloud.

## Manual execution

Manully running the go tests can save time during initial development. Requires active aws credentials.

```
python test_cloud_register_manual.py --cloud-provider AWS --local_path ./anyscale-v2-e2e-public-test
```


#### Retrieving AWS credentials

AWS Credentials can be retreived using the aws cli. It then needs to be exported to the env variable AWS_PROFILE
```
aws sso login --profile <profile_name>
export AWS_PROFILE="<profile_name>"
```

#### Notes

This python script replaces Go unit tests which were not kept up-to-date and were not providing a full E2E test.
Additional E2E tests can be created if useful.
