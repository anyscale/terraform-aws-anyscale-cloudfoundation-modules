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

	// Run `terraform output` to get the value of an output variable. If it's not available, fail the test.
	// All Defaults - this should generate a VPC, but nothing in it. Not even subnets.
	allDefaultsAnyscaleArnOutput := terraform.OutputRequired(t, terraformOptions, "all_defaults_arn")
	assert.Contains(t, allDefaultsAnyscaleArnOutput, "arn:aws:vpc::")
	assert.Contains(t, allDefaultsAnyscaleArnOutput, "vpc-")

	allDefaultsAnyscaleIdOutput := terraform.OutputRequired(t, terraformOptions, "all_defaults_id")
	assert.Contains(t, allDefaultsAnyscaleIdOutput, "vpc-")

	allDefaultsAnyscaleBucketRegion := terraform.OutputRequired(t, terraformOptions, "all_defaults_cidr_range")
	assert.Contains(t, allDefaultsAnyscaleBucketRegion, "172.20.0.0/16")

	// Minimum VPC
	minimumVPCArnOutput := terraform.OutputRequired(t, terraformOptions, "minimum_anyscale_vpc_requirements_arn")
	assert.Contains(t, minimumVPCArnOutput, "arn:aws:vpc::")
	assert.Contains(t, minimumVPCArnOutput, "tftest-minimum_anyscale_vpc")

	minimumVPCIdOutput := terraform.OutputRequired(t, terraformOptions, "minimum_anyscale_vpc_requirements_id")
	assert.Contains(t, minimumVPCIdOutput, "tftest-minimum_anyscale_vpc")

	minimumVPCCidrRange := terraform.OutputRequired(t, terraformOptions, "minimum_anyscale_vpc_requirements_cidr_range")
	assert.Contains(t, minimumVPCCidrRange, "172.21.0.0/16")

	// Public/Private VPC
	publicPrivateArnOutput := terraform.OutputRequired(t, terraformOptions, "public_private_vpc_arn")
	assert.Contains(t, publicPrivateArnOutput, "arn:aws:vpc::")
	assert.Contains(t, publicPrivateArnOutput, "tftest-publicprivate_anyscale_vpc")

	publicPrivateIdOutput := terraform.OutputRequired(t, terraformOptions, "public_private_vpc_id")
	assert.Contains(t, publicPrivateIdOutput, "tftest-publicprivate_anyscale_vpc")

	publicPrivateVpcCidrRange := terraform.OutputRequired(t, terraformOptions, "public_private_vpc_cidr_range")
	assert.Contains(t, publicPrivateVpcCidrRange, "172.22.0.0/16")

	publicPrivatePublicCidrRange := terraform.OutputRequired(t, terraformOptions, "public_private_public_subnet_cidrs")
	assert.Contains(t, publicPrivatePublicCidrRange, "172.22.102.0/24")

	publicPrivatePrivateCidrRange := terraform.OutputRequired(t, terraformOptions, "public_private_private_subnet_cidrs")
	assert.Contains(t, publicPrivatePrivateCidrRange, "172.22.20.0/24")

	// Kitchen Sink Cluster Node Custom Policy
	kitchenSyncArnOutput := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_arn")
	assert.Contains(t, kitchenSyncArnOutput, "arn:aws:vpc::")
	assert.Contains(t, kitchenSyncArnOutput, "tftest-kitchen_sink")

	kitchenSyncIdOutput := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_id")
	assert.Contains(t, kitchenSyncIdOutput, "tftest-kitchen_sink")

	kitchenSyncCidrRange := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_vpc_cidr_range")
	assert.Contains(t, kitchenSyncCidrRange, "172.23.0.0/16")

	kitchenSyncPublicCidrRange := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_public_subnet_cidrs")
	assert.Contains(t, kitchenSyncPublicCidrRange, "172.22.102.0/24")

	kitchenSyncPrivateCidrRange := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_private_subnet_cidrs")
	assert.Contains(t, kitchenSyncPrivateCidrRange, "172.22.20.0/24")

	kitchenSyncAvailabilityZones := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_availability_zones")
	assert.Contains(t, kitchenSyncAvailabilityZones, "us-east-2a")
	assert.Contains(t, kitchenSyncAvailabilityZones, "us-east-2b")
	assert.Contains(t, kitchenSyncAvailabilityZones, "us-east-2c")
}
