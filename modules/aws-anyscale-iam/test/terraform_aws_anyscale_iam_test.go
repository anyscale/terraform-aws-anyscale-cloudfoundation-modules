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
	allDefaultsAnyscaleArnOutput := terraform.OutputRequired(t, terraformOptions, "all_defaults_arn")
	assert.Contains(t, allDefaultsAnyscaleArnOutput, "arn:aws:iam::")
	assert.Contains(t, allDefaultsAnyscaleArnOutput, "anyscale-")

	onlyClusterNodeArnOutput := terraform.OutputRequired(t, terraformOptions, "node_cluster_role_arn")
	assert.Contains(t, onlyClusterNodeArnOutput, "arn:aws:iam::")
	assert.Contains(t, onlyClusterNodeArnOutput, "anyscale-cluster-node-")

	// Kitchen Sinc Anyscale Access Role
	iamKitchenSyncAnyscaleArnOutput := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_anyscale_role_arn")
	assert.Contains(t, iamKitchenSyncAnyscaleArnOutput, "arn:aws:iam::")
	assert.Contains(t, iamKitchenSyncAnyscaleArnOutput, "anyscale-access-role-testrole")

	iamKitchenSyncAnyscaleNameOutput := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_anyscale_role_name")
	assert.Contains(t, iamKitchenSyncAnyscaleNameOutput, "anyscale-access-role-testrole")

	iamKitchenSyncAnyscalePathOutput := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_anyscale_role_path")
	assert.Contains(t, iamKitchenSyncAnyscalePathOutput, "/testpath/")

	// Kitchen Sink Steady State Policy
	iamKitchenSyncSteadyStatePolicyArnOutput := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_steadystate_policy_arn")
	assert.Contains(t, iamKitchenSyncSteadyStatePolicyArnOutput, "arn:aws:iam::")
	assert.Contains(t, iamKitchenSyncSteadyStatePolicyArnOutput, "anyscale-steadystate-policy-testpolicy")

	iamKitchenSyncSteadyStatePolicyNameOutput := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_steadystate_policy_name")
	assert.Contains(t, iamKitchenSyncSteadyStatePolicyNameOutput, "anyscale-steadystate-policy-testpolicy")

	iamKitchenSyncSteadyStatePolicyPathOutput := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_steadystate_policy_path")
	assert.Contains(t, iamKitchenSyncSteadyStatePolicyPathOutput, "/testpath/")

	// Kitchen Sink Anyscale Services v2 Policy
	iamKitchenSyncServicesv2PolicyArnOutput := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_servicesv2_policy_arn")
	assert.Contains(t, iamKitchenSyncServicesv2PolicyArnOutput, "arn:aws:iam::")
	assert.Contains(t, iamKitchenSyncServicesv2PolicyArnOutput, "anyscale-servicesv2-policy-testpolicy")

	iamKitchenSyncServicesv2PolicyNameOutput := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_servicesv2_policy_name")
	assert.Contains(t, iamKitchenSyncServicesv2PolicyNameOutput, "anyscale-servicesv2-policy-testpolicy")

	iamKitchenSyncServicesv2PolicyPathOutput := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_servicesv2_policy_path")
	assert.Contains(t, iamKitchenSyncServicesv2PolicyPathOutput, "/testpath/")

	// Kitchen Sink Access Custom Policy
	iamKitchenSyncCustomPolicyArnOutput := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_access_custom_policy_arn")
	assert.Contains(t, iamKitchenSyncCustomPolicyArnOutput, "arn:aws:iam::")
	assert.Contains(t, iamKitchenSyncCustomPolicyArnOutput, "anyscale-custom-policy-testpolicy")

	iamKitchenCustomPolicyNameOutput := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_access_custom_policy_name")
	assert.Contains(t, iamKitchenCustomPolicyNameOutput, "anyscale-custom-policy-testpolicy")

	iamKitchenSyncCustomPolicyPathOutput := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_access_custom_policy_path")
	assert.Contains(t, iamKitchenSyncCustomPolicyPathOutput, "/testcustompath/")

	// Kitchen Sink Cluster Node Role
	iamKitchenSyncClusterNodeArnOutput := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_cluster_node_role_arn")
	assert.Contains(t, iamKitchenSyncClusterNodeArnOutput, "arn:aws:iam::")
	assert.Contains(t, iamKitchenSyncClusterNodeArnOutput, "instance-profile/testclusternodepath/anyscale-cluster-node-role-testrole")

	iamKitchenSyncClusterNodeNameOutput := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_cluster_node_role_name")
	assert.Contains(t, iamKitchenSyncClusterNodeNameOutput, "anyscale-cluster-node-role-testrole")

	iamKitchenSyncClusterNodePathOutput := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_cluster_node_profile_path")
	assert.Contains(t, iamKitchenSyncClusterNodePathOutput, "/testclusternodepath/")

	iamKitchenSyncClusterNodeInstsanceProfileId := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_cluster_node_instance_profile_id")
	assert.Contains(t, iamKitchenSyncClusterNodeInstsanceProfileId, "anyscale-cluster-node-role-testrole")

	// Kitchen Sink Cluster Node Custom Policy
	iamKitchenSyncClusterNodeCustomPolicyArnOutput := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_cluster_node_custom_policy_arn")
	assert.Contains(t, iamKitchenSyncClusterNodeCustomPolicyArnOutput, "arn:aws:iam::")
	assert.Contains(t, iamKitchenSyncClusterNodeCustomPolicyArnOutput, "anyscale-cluster-node-policy-testpolicy")

	iamKitchenSyncClusterNodeCustomPolicyNameOutput := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_cluster_node_custom_policy_name")
	assert.Contains(t, iamKitchenSyncClusterNodeCustomPolicyNameOutput, "anyscale-cluster-node-policy-testpolicy")

	iamKitchenSyncClusterNodeCustomPolicyPathOutput := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_cluster_node_custom_policy_path")
	assert.Contains(t, iamKitchenSyncClusterNodeCustomPolicyPathOutput, "/testclusternodepath/")

	// Kitchen Sink IAM S3 Policy
	iamKitchenSyncIAMS3PolicyArnOutput := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_iam_s3_policy_arn")
	assert.Contains(t, iamKitchenSyncIAMS3PolicyArnOutput, "arn:aws:iam::")
	assert.Contains(t, iamKitchenSyncIAMS3PolicyArnOutput, "aanyscale-s3-testpolicy-")

	iamKitchenSyncIAMS3PolicyNameOutput := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_iam_s3_policy_name")
	assert.Contains(t, iamKitchenSyncIAMS3PolicyNameOutput, "anyscale-s3-testpolicy-")

	iamKitchenSyncIAMS3PolicyPathOutput := terraform.OutputRequired(t, terraformOptions, "kitchen_sink_iam_s3_policy_path")
	assert.Contains(t, iamKitchenSyncIAMS3PolicyPathOutput, "/tests3path/")
}
