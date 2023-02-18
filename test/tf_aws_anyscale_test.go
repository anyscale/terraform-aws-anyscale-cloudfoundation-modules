package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"

	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

type IP struct {
	Query string
}

func getip2() string {
	req, err := http.Get("http://ip-api.com/json/")
	if err != nil {
		return err.Error()
	}
	defer req.Body.Close()

	body, err := io.ReadAll(req.Body)
	if err != nil {
		return err.Error()
	}

	var ip IP
	json.Unmarshal(body, &ip)

	return ip.Query
}

func TestAnyscaleV1Resources(t *testing.T) {
	t.Parallel()

	// awsRegion := aws.GetRandomStableRegion(t, nil, nil)
	awsRegion := "us-east-2"
	expectedS3TagValue := fmt.Sprintf("tag-%s", random.UniqueId())
	// expectedS3Name := fmt.Sprintf("ex-%s", strings.ToLower(random.UniqueId()))

	terraformOptions := &terraform.Options{
		// The path to where your Terraform code is located
		TerraformDir: "./anyscale-v1-test",
		Vars: map[string]interface{}{
			"aws_region":                awsRegion,
			"anyscale_cloud_id":         "cld_automated_terraform_test",
			"anyscale_deploy_env":       "test",
			"existing_vpc_s3_tag_value": expectedS3TagValue,
		},
		Upgrade: true,
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable. If it's not available, fail the test.
	// Anyscale v1 Stack resources with minimal parameters
	anyscale_v1_vpc_id := terraform.OutputRequired(t, terraformOptions, "anyscale_v1_vpc_id")
	assert.Contains(t, anyscale_v1_vpc_id, "vpc-")

	anyscale_v1_vpc_public_subnet_ids := terraform.OutputRequired(t, terraformOptions, "anyscale_v1_vpc_public_subnet_ids")
	assert.Contains(t, anyscale_v1_vpc_public_subnet_ids, "subnet-")

	anyscale_v1_s3_bucket_id := terraform.OutputRequired(t, terraformOptions, "anyscale_v1_s3_bucket_id")
	assert.Contains(t, anyscale_v1_s3_bucket_id, "anyscale-")

	anyscale_v1_security_group_id := terraform.OutputRequired(t, terraformOptions, "anyscale_v1_security_group_id")
	assert.Contains(t, anyscale_v1_security_group_id, "sg-")

	anyscale_v1_iam_role_arn := terraform.OutputRequired(t, terraformOptions, "anyscale_v1_iam_role_arn")
	assert.Contains(t, anyscale_v1_iam_role_arn, "arn:aws:iam::")
	assert.Contains(t, anyscale_v1_iam_role_arn, "anyscale-iam-role-")

	anyscale_v1_iam_instance_role_arn := terraform.OutputRequired(t, terraformOptions, "anyscale_v1_iam_instance_role_arn")
	assert.Contains(t, anyscale_v1_iam_instance_role_arn, "arn:aws:iam::")
	assert.Contains(t, anyscale_v1_iam_instance_role_arn, "anyscale-cluster-node-")

	anyscale_v1_efs_id := terraform.OutputRequired(t, terraformOptions, "anyscale_v1_efs_id")
	assert.Contains(t, anyscale_v1_efs_id, "fs-")

	// Anyscale v1 Stack with existing VPC
	anyscale_v1_existing_vpc_s3_bucket_id := terraform.OutputRequired(t, terraformOptions, "anyscale_v1_existing_vpc_s3_bucket_id")
	assert.Contains(t, anyscale_v1_existing_vpc_s3_bucket_id, "anyscale-")
	// Verify that tag was applied.
	anyscale_v1_existing_vpc_s3_bucket_tag_id := aws.FindS3BucketWithTag(t, awsRegion, "s3_tagging", expectedS3TagValue)
	assert.Contains(t, anyscale_v1_existing_vpc_s3_bucket_tag_id, anyscale_v1_existing_vpc_s3_bucket_id)

	anyscale_v1_existing_vpc_security_group_id := terraform.OutputRequired(t, terraformOptions, "anyscale_v1_existing_vpc_security_group_id")
	assert.Contains(t, anyscale_v1_existing_vpc_security_group_id, "sg-")

	anyscale_v1_existing_vpc_iam_role_arn := terraform.OutputRequired(t, terraformOptions, "anyscale_v1_existing_vpc_iam_role_arn")
	assert.Contains(t, anyscale_v1_existing_vpc_iam_role_arn, "arn:aws:iam::")
	assert.Contains(t, anyscale_v1_existing_vpc_iam_role_arn, "anyscale-iam-role-")

	anyscale_v1_existing_vpc_iam_instance_role_arn := terraform.OutputRequired(t, terraformOptions, "anyscale_v1_existing_vpc_iam_instance_role_arn")
	assert.Contains(t, anyscale_v1_existing_vpc_iam_instance_role_arn, "arn:aws:iam::")
	assert.Contains(t, anyscale_v1_existing_vpc_iam_instance_role_arn, "anyscale-cluster-node-")

	anyscale_v1_existing_vpc_efs_id := terraform.OutputRequired(t, terraformOptions, "anyscale_v1_existing_vpc_efs_id")
	assert.Contains(t, anyscale_v1_existing_vpc_efs_id, "fs-")
}

func TestAnyscaleV2Resources(t *testing.T) {
	t.Parallel()

	myPublicIp := getip2()
	// awsRegion := aws.GetRandomStableRegion(t, nil, nil)
	awsRegion := "us-east-2"
	expectedS3TagValue := fmt.Sprintf("tag-%s", random.UniqueId())
	// expectedS3Name := fmt.Sprintf("ex-%s", strings.ToLower(random.UniqueId()))

	terraformOptions := &terraform.Options{
		// The path to where your Terraform code is located
		TerraformDir: "./anyscale-v2-test",
		Vars: map[string]interface{}{
			"aws_region":                   awsRegion,
			"anyscale_cloud_id":            "cld_automated_terraform_test",
			"anyscale_deploy_env":          "test",
			"existing_vpc_s3_tag_value":    expectedS3TagValue,
			"customer_ingress_cidr_ranges": myPublicIp + "/32",
		},
		Upgrade: true,
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)
}
