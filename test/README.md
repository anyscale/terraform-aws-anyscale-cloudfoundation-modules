# aws-anyscale module (and sub-modules) unit tests
Requirements:
* Go language (this can be installed locally via `brew install go`)
* terratest which is installed with `go mod tidy` (see below)
* A unit test file whose suffix is: _test.go

More info can be found [here](https://terratest.gruntwork.io/docs/getting-started/quick-start/)

## Tests Breakdown

### anyscale-v2-tests

- anyscale_v2_00_test - This creates resources for an Anyscale v2.0 stack using as many defaults as possible.
   - IAM Roles
   - S3 Bucket
   - VPC with publicly routed subnets (no internal)
   - VPC Security Group allowing access from a customer defined public IP
   - EFS

- anyscale_v2_01_test - This creates resources for an Anyscale v2.0 Stack with an existing VPC and an existing S3 bucket. This utilizes an existing VPC and is meant to be testing v2 Customer Defined Networking:
   - IAM Roles
   - S3 Bucket
   - VPC Security Group that is locked down with no public access and no access from Anyscale IPs
   - EFS

- anyscale_v2_02_private_subnets_test - This creates resources for an Anyscale v2.0 Stack with a Private Networking VPC.
  - IAM Roles
  - S3 Bucket
  - VPC with privately routed subnets (no external subnets for Anyscale Clusters)
  - VPC Security Group allowing access from internal IPs
  - EFS

- anyscale_v2_03_common_name_test - This creates resources for an Anyscale v2.0 Stack with common resource names.
  - IAM Roles
  - S3 Bucket
  - VPC with publicly routed subnets (no internal)
  - VPC Security group
  - EFS

- anyscale_v2_04_create_endpoints - This uses an existing VPC but creates VPC endpoints - as well as the other resources needed for an Anyscale v2.0 stack. It uses an existing VPC and existing subnets.
  - IAM Roles
  - S3 Bucket
  - VPC Endpoints for S3
  - VPC Security Group
  - EFS

- anyscale_v2_05_e2e_public_test - This is used for automated testing of the end to end process for creating an Anyscale cloud with Terraform and `anyscale cloud register` - it's similar to the common_name test.
  - IAM Roles
  - S3 Bucket
  - VPC with publicly routed subnets (no internal)
  - VPC Security Group
  - EFS

- anyscale_v2_06_e2e_private_test - This is used for automated testing of the end to end process for creating an Anyscale cloud with Terraform and `anyscale cloud register` - it's similar to the private_subnets_test.
  - IAM Roles
  - S3 Bucket
  - VPC with privately routed subnets (no external subnets for Anyscale Clusters)
  - VPC Security Group
  - EFS

#### Manual execution
Manully running the go tests can save time during initial development. Requires active aws credentials.
```
cd test
go mod init "<module_name>"
go mod tidy
go test -v
```
Where `<module_name>` is the name of the terraform module (can also be `github.com/<your_repo_name>`).

To execute a specific test (when there are multiple tests), you can use:
```
cd test
go test -v -run <TestName>
#example
go test -v -run TestAnyscaleV2Resources
```

#### Other useful go commands
`go get -t -u` This updates test modules to the latest versions. Must be followed with `go mod tidy`

#### Retrieving AWS credentials
AWS Credentials can be retreived using the aws cli. It then needs to be exported to the env variable AWS_PROFILE
```
aws sso login --profile <profile_name>
export AWS_PROFILE="<profile_name>"
```
