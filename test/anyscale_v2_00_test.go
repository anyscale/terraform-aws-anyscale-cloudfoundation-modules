package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"encoding/json"
	"io"
	"net/http"
)

type IP struct {
	Query string
}

func GetIP() string {

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

func TestAnyscaleV2(t *testing.T) {
	t.Parallel()

	myPublicIp := GetIP()
	// awsRegion := aws.GetRandomStableRegion(t, nil, nil)
	awsRegion := "us-east-2"

	terraformOptions := &terraform.Options{
		// The path to where your Terraform code is located
		TerraformDir: "../examples/anyscale-v2",
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
	// Anyscale v2 Stack resources with minimal parameters
	// --------------------------------------
	anyscale_v2_vpc_id := terraform.OutputRequired(t, terraformOptions, "anyscale_v2_vpc_id")
	assert.Contains(t, anyscale_v2_vpc_id, "vpc-")
	aws.GetVpcById(t, anyscale_v2_vpc_id, awsRegion)

	anyscale_v2_vpc_public_subnet_ids := terraform.OutputRequired(t, terraformOptions, "anyscale_v2_vpc_public_subnet_ids")
	assert.Contains(t, anyscale_v2_vpc_public_subnet_ids, "subnet-")
	anyscale_v2_subnets := aws.GetSubnetsForVpc(t, anyscale_v2_vpc_id, awsRegion)
	require.Equal(t, 3, len(anyscale_v2_subnets))

	anyscale_v2_s3_bucket_id := terraform.OutputRequired(t, terraformOptions, "anyscale_v2_s3_bucket_id")
	assert.Contains(t, anyscale_v2_s3_bucket_id, "anyscale-")
	// Verify that our Bucket has a policy attached
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
