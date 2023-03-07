package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"fmt"
)

func TestAnyscalev2_privatesubnets(t *testing.T) {
	t.Parallel()

	// awsRegion := aws.GetRandomStableRegion(t, nil, nil)
	awsRegion := "us-east-2"
	expectedS3TagValue := fmt.Sprintf("tag-%s", random.UniqueId())
	// expectedS3Name := fmt.Sprintf("ex-%s", strings.ToLower(random.UniqueId()))

	terraformOptions := &terraform.Options{
		// The path to where your Terraform code is located
		TerraformDir: "../examples/anyscale-v2-privatesubnets",
		Vars: map[string]interface{}{
			"aws_region":          awsRegion,
			"anyscale_cloud_id":   "cld_automated_terraform_test",
			"anyscale_deploy_env": "test",
			"s3_tag_value":        expectedS3TagValue,
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
	anyscale_v2_vpc_id := terraform.OutputRequired(t, terraformOptions, "anyscale_v2_vpc_id")
	assert.Contains(t, anyscale_v2_vpc_id, "vpc-")
	vpcTest := aws.GetVpcById(t, anyscale_v2_vpc_id, awsRegion)
	assert.Equal(t, anyscale_v2_vpc_id, vpcTest.Id)
	vpcTags := aws.GetTagsForVpc(t, anyscale_v2_vpc_id, awsRegion)
	testingVPCTag, containsTestingVPCTag := vpcTags["vpc_tag_test"]
	assert.True(t, containsTestingVPCTag)
	assert.Equal(t, "private_vpc", testingVPCTag)

	// Check subnets
	anyscale_v2_public_subnet_ids := terraform.OutputRequired(t, terraformOptions, "anyscale_v2_public_subnet_ids")
	assert.Contains(t, anyscale_v2_public_subnet_ids, "subnet-")
	anyscale_v2_private_subnet_ids := terraform.OutputList(t, terraformOptions, "anyscale_v2_private_subnet_ids")
	assert.Contains(t, anyscale_v2_private_subnet_ids[0], "subnet-")

	anyscale_v2_subnets := aws.GetSubnetsForVpc(t, anyscale_v2_vpc_id, awsRegion)
	require.Equal(t, 6, len(anyscale_v2_subnets))

	subnetTags := aws.GetTagsForSubnet(t, anyscale_v2_subnets[0].Id, awsRegion)
	testingSubnetTag, containsTestingSubnetTag := subnetTags["vpc_tag_test"]
	assert.True(t, containsTestingSubnetTag)
	assert.Equal(t, "private_vpc", testingSubnetTag)

	assert.False(t, aws.IsPublicSubnet(t, anyscale_v2_private_subnet_ids[0], awsRegion))

	// Check S3
	anyscale_v2_s3_bucket_id := terraform.OutputRequired(t, terraformOptions, "anyscale_v2_s3_bucket_id")
	assert.Contains(t, anyscale_v2_s3_bucket_id, "private-vpc-")

	anyscale_v2_s3_bucket_tag_id := aws.FindS3BucketWithTag(t, awsRegion, "s3_tagging", expectedS3TagValue)
	assert.Contains(t, anyscale_v2_s3_bucket_tag_id, anyscale_v2_s3_bucket_id)

	aws.AssertS3BucketPolicyExists(t, awsRegion, anyscale_v2_s3_bucket_id)

	// Check other items
	anyscale_v2_security_group_id := terraform.OutputRequired(t, terraformOptions, "anyscale_v2_security_group_id")
	assert.Contains(t, anyscale_v2_security_group_id, "sg-")

	anyscale_v2_iam_role_arn := terraform.OutputRequired(t, terraformOptions, "anyscale_v2_iam_role_arn")
	assert.Contains(t, anyscale_v2_iam_role_arn, "arn:aws:iam::")
	assert.Contains(t, anyscale_v2_iam_role_arn, "private-vpc-")

	anyscale_v2_iam_instance_role_arn := terraform.OutputRequired(t, terraformOptions, "anyscale_v2_iam_instance_role_arn")
	assert.Contains(t, anyscale_v2_iam_instance_role_arn, "arn:aws:iam::")
	assert.Contains(t, anyscale_v2_iam_instance_role_arn, "private-vpc-")

	anyscale_v2_efs_id := terraform.OutputRequired(t, terraformOptions, "anyscale_v2_efs_id")
	assert.Contains(t, anyscale_v2_efs_id, "fs-")
}
