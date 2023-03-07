package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	// "github.com/stretchr/testify/require"
)

func TestAnyscalev2_createendpoints(t *testing.T) {
	t.Parallel()

	// awsRegion := aws.GetRandomStableRegion(t, nil, nil)
	awsRegion := "us-east-2"
	myPublicIp := GetIP()

	terraformOptions := &terraform.Options{
		// The path to where your Terraform code is located
		TerraformDir: "../examples/anyscale-v2-createendpoints",
		Vars: map[string]interface{}{
			"aws_region":                   awsRegion,
			"anyscale_cloud_id":            "cld_automated_terraform_test",
			"anyscale_deploy_env":          "test",
			"customer_ingress_cidr_ranges": myPublicIp + "/32",
		},
		Upgrade: true,
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// --------------------------------------
	// Anyscale v2 Stack - Creating Endpoints, Not creating VPC
	// --------------------------------------
	// Check Routes
	anyscale_v2_s3_bucket_id := terraform.OutputRequired(t, terraformOptions, "anyscale_v2_s3_bucket_id")
	assert.Contains(t, anyscale_v2_s3_bucket_id, "anyscale-")
	// Verify that custom tag was applied.
	// anyscale_v2_s3_bucket_tag_id := aws.FindS3BucketWithTag(t, awsRegion, "s3_tagging", expectedS3TagValue)
	// assert.Contains(t, anyscale_v2_s3_bucket_tag_id, anyscale_v2_s3_bucket_id)
	// Verify that the S3 Bucket Policy exists
	aws.AssertS3BucketPolicyExists(t, awsRegion, anyscale_v2_s3_bucket_id)

	anyscale_v2_security_group_id := terraform.OutputRequired(t, terraformOptions, "anyscale_v2_security_group_id")
	assert.Contains(t, anyscale_v2_security_group_id, "sg-")

	anyscale_v2_iam_role_arn := terraform.OutputRequired(t, terraformOptions, "anyscale_v2_iam_role_arn")
	assert.Contains(t, anyscale_v2_iam_role_arn, "arn:aws:iam::")
	assert.Contains(t, anyscale_v2_iam_role_arn, "anyscale-iam-role-")

	anyscale_v2_iam_instance_role_arn := terraform.OutputRequired(t, terraformOptions, "anyscale_v2_iam_instance_role_arn")
	assert.Contains(t, anyscale_v2_iam_instance_role_arn, "arn:aws:iam::")
	assert.Contains(t, anyscale_v2_iam_instance_role_arn, "anyscale-cluster-node-")

	anyscale_v2_efs_id := terraform.OutputRequired(t, terraformOptions, "anyscale_v2_efs_id")
	assert.Contains(t, anyscale_v2_efs_id, "fs-")
}
