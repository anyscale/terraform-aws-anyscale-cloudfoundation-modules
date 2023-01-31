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
		TerraformDir: "../examples/anyscale-test",
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

	// Run `terraform output` to get the value of an output variable. If it's not available, fail the test.
	allDefaultsAnyscaleArnOutput := terraform.OutputRequired(t, terraformOptions, "all_defaults_arn")
	assert.Contains(t, allDefaultsAnyscaleArnOutput, "arn:aws:elasticfilesystem")
	assert.Contains(t, allDefaultsAnyscaleArnOutput, awsRegion)
	assert.Contains(t, allDefaultsAnyscaleArnOutput, "fs-")

	allDefaultsAnyscaleIdOutput := terraform.OutputRequired(t, terraformOptions, "all_defaults_id")
	assert.Contains(t, allDefaultsAnyscaleIdOutput, "fs-")

	// Kitchen Sink Output Tests
	kitchenSinkArnOutput := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_arn")
	assert.Contains(t, kitchenSinkArnOutput, "arn:aws:elasticfilesystem")
	assert.Contains(t, kitchenSinkArnOutput, awsRegion)
	assert.Contains(t, kitchenSinkArnOutput, "fs-")

	kitchenSinkIdOutput := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_id")
	assert.Contains(t, kitchenSinkIdOutput, "fs-")
}
