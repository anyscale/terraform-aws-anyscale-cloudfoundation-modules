package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestAnyscaleResources(t *testing.T) {
	t.Parallel()

	awsRegion := aws.GetRandomStableRegion(t, nil, nil)

	terraformOptions := &terraform.Options{
		// The path to where your Terraform code is located
		TerraformDir: "./anyscale-test",
		Vars: map[string]interface{}{
			"aws_region":          awsRegion,
			"anyscale_cloud_id":   "cld_automated_terraform_test",
			"anyscale_deploy_env": "test",
		},
		Upgrade: true,
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	s3BucketDefaultsIdOutput := terraform.OutputRequired(t, terraformOptions, "s3_bucket_id_defaults")
	s3BucketCustomPolicyIdOutput := terraform.OutputRequired(t, terraformOptions, "s3_bucket_custom_policy_id")

	// GetS3BucketPolicy
	defaultBucketPolicy := aws.GetS3BucketPolicy(t, awsRegion, s3BucketDefaultsIdOutput)
	assert.Contains(t, defaultBucketPolicy, "AllowAnyscaleResources")

	customBucketPolicy := aws.GetS3BucketPolicy(t, awsRegion, s3BucketCustomPolicyIdOutput)
	assert.Contains(t, customBucketPolicy, "TestCustomS3Policy")

}
