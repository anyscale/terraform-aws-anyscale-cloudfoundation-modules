package test

import (
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestAnyscalev2_commonname(t *testing.T) {
	t.Parallel()

	// awsRegion := aws.GetRandomStableRegion(t, nil, nil)
	awsRegion := "us-east-2"
	commonName := strings.ToLower("anyscale-pfx-" + random.UniqueId())
	myPublicIp := GetIP()

	terraformOptions := &terraform.Options{
		// The path to where your Terraform code is located
		TerraformDir: "../examples/anyscale-v2-commonname",
		Vars: map[string]interface{}{
			"aws_region":                   awsRegion,
			"anyscale_cloud_id":            "cld_automated_terraform_test",
			"anyscale_deploy_env":          "test",
			"customer_ingress_cidr_ranges": myPublicIp + "/32",
			"common_prefix":                commonName,
		},
		Upgrade: true,
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// --------------------------------------
	// Anyscale v2 Stack with Private Networking VPC
	// --------------------------------------
	// Check VPC
	anyscale_v2_vpc_id := terraform.OutputRequired(t, terraformOptions, "anyscale_v2_vpc_id")
	assert.Contains(t, anyscale_v2_vpc_id, "vpc-")
	vpcTags := aws.GetTagsForVpc(t, anyscale_v2_vpc_id, awsRegion)
	testingVpcNameTag, containsVpcNameTag := vpcTags["Name"]
	assert.True(t, containsVpcNameTag)
	assert.Contains(t, testingVpcNameTag, commonName)

	// Check subnets
	anyscale_v2_public_subnet_ids := terraform.OutputRequired(t, terraformOptions, "anyscale_v2_public_subnet_ids")
	assert.Contains(t, anyscale_v2_public_subnet_ids, "subnet-")
	anyscale_v2_private_subnet_ids := terraform.OutputList(t, terraformOptions, "anyscale_v2_private_subnet_ids")
	assert.Contains(t, anyscale_v2_private_subnet_ids[0], "subnet-")

	anyscale_v2_subnets := aws.GetSubnetsForVpc(t, anyscale_v2_vpc_id, awsRegion)
	require.Equal(t, 6, len(anyscale_v2_subnets))

	subnetTags := aws.GetTagsForSubnet(t, anyscale_v2_subnets[0].Id, awsRegion)
	testingSubnetTag, containsTestingSubnetTag := subnetTags["Name"]
	assert.True(t, containsTestingSubnetTag)
	assert.Contains(t, testingSubnetTag, commonName)

	assert.False(t, aws.IsPublicSubnet(t, anyscale_v2_private_subnet_ids[0], awsRegion))

	// Check S3
	anyscale_v2_s3_bucket_id := terraform.OutputRequired(t, terraformOptions, "anyscale_v2_s3_bucket_id")
	assert.Contains(t, anyscale_v2_s3_bucket_id, commonName)
	aws.AssertS3BucketPolicyExists(t, awsRegion, anyscale_v2_s3_bucket_id)

	anyscale_v2_security_group_id := terraform.OutputRequired(t, terraformOptions, "anyscale_v2_security_group_id")
	assert.Contains(t, anyscale_v2_security_group_id, "sg-")

	anyscale_v2_iam_role_arn := terraform.OutputRequired(t, terraformOptions, "anyscale_v2_iam_role_arn")
	assert.Contains(t, anyscale_v2_iam_role_arn, "arn:aws:iam::")
	assert.Contains(t, anyscale_v2_iam_role_arn, commonName)

	anyscale_v2_iam_instance_role_arn := terraform.OutputRequired(t, terraformOptions, "anyscale_v2_iam_instance_role_arn")
	assert.Contains(t, anyscale_v2_iam_instance_role_arn, "arn:aws:iam::")
	assert.Contains(t, anyscale_v2_iam_instance_role_arn, commonName)

	anyscale_v2_efs_id := terraform.OutputRequired(t, terraformOptions, "anyscale_v2_efs_id")
	assert.Contains(t, anyscale_v2_efs_id, "fs-")
}
