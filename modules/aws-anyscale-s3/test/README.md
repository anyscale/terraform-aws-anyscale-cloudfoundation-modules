# aws-anyscale-s3 module unit tests
Requirements:
* Go language (this can be installed locally via `brew install go`)
* terratest which is installed with `go mod tidy` (see below)
* A unit test file whose suffix is: _test.go

More info can be found [here](https://terratest.gruntwork.io/docs/getting-started/quick-start/)

#### Manual execution
Manully running the go tests can save time during initial development. Requires active aws credentials.
```
cd test
go mod init "<module_name>"
go mod tidy
go test -v
```
Where `<module_name>` is the name of the terraform module (can also be `github.com/<your_repo_name>`).

#### Other useful go commands
`go get -t -u` This updates test modules to the latest versions. Must be followed with `go mod tidy`

#### Retrieving AWS credentials
AWS Credentials can be retreived using the aws cli. It then needs to be exported to the env variable AWS_PROFILE
```
aws sso login --profile <profile_name>
export AWS_PROFILE="<profile_name>"
```
