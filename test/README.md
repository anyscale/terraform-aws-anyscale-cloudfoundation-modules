# aws-anyscale module (and sub-modules) unit tests
Requirements:
* Go language (this can be installed locally via `brew install go`)
* terratest which is installed with `go mod tidy` (see below)
* A unit test file whose suffix is: _test.go

More info can be found [here](https://terratest.gruntwork.io/docs/getting-started/quick-start/)

## Tests Breakdown

### anyscale-v1-test

This will create two sets of resources for an Anyscale v1.0 Stack.

The first includes as many defaults as possible including:
   - IAM Roles
   - S3 Bucket
   - VPC with publicly routed subnets (no internal)
   - VPC Security Group allowing public from Anyscale and 0.0.0.0/0
   - EFS

The second utilizes an existing VPC and creates:
   - IAM Roles
   - S3 Bucket
   - VPC Security Group allowing public from Anyscale and 0.0.0.0/0
   - EFS

### anyscale-v2-test - NOT DONE

This will create three sets of resources for Anyscale v2.0 Stacks.

The first includes as many defaults as possible and duplicates the v1 Stack resources above minus the Anyscale Public Ingress:
   - IAM Roles
   - S3 Bucket
   - VPC with publicly routed subnets (no internal)
   - VPC Security Group allowing access from a customer defined public IP
   - EFS

The second utilizes an existing VPC and is meant to be testing the v2 Customer Defined Networking solution with no public IPs and locked down ingress in the security group configuration. It creates:
   - IAM Roles
   - S3 Bucket
   - VPC Security Group that is locked down with no public access and no access from Anyscale IPs
   - EFS

The third creates resources for an Anyscale v2.0 Stack with an existing VPC and an existing S3 bucket. This is still utilizing an existing VPC and is meant to be testing v2 Customer Defined Networking, an existing S3, etc. It creates:
   - IAM Roles
   - VPC Security Group that is locked down with no public access and no access from Anyscale IPs
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
