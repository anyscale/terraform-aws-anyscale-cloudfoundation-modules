# ---------------------------------------------------------------------------------------------------------------------
# CREATE Anyscale AWS IAM Resources
# This template creates IAM resources for Anyscale
# ---------------------------------------------------------------------------------------------------------------------
locals {
  full_tags = merge(tomap({
    anyscale-cloud-id           = var.anyscale_cloud_id,
    anyscale-deploy-environment = var.anyscale_deploy_env
    }),
    var.tags
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# Create the assumable role and the cluster node role/instance profile for Anyscale with no optional parameters
# ---------------------------------------------------------------------------------------------------------------------
module "all_defaults" {
  source = "../.."

  module_enabled = true
  tags           = local.full_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Create the cluster node and instance profile for Anyscale with no optional parameters. No access role.
# ---------------------------------------------------------------------------------------------------------------------
module "iam_cluster_node_instance_profile" {
  source = "../.."

  module_enabled                       = true
  create_anyscale_access_role          = false
  create_cluster_node_instance_profile = true
  tags                                 = local.full_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Use all params and build both roles.
# ---------------------------------------------------------------------------------------------------------------------
module "kitchen_sink" {
  source = "../.."

  module_enabled = true

  create_anyscale_access_role      = true
  anyscale_access_role_name        = "anyscale-access-role-testrole"
  anyscale_access_role_path        = "/testpath/"
  anyscale_access_role_description = "Anyscale TESTROLE Description"

  create_anyscale_access_steadystate_policy      = true
  anyscale_access_steadystate_policy_name        = "anyscale-steadystate-policy-testpolicy"
  anyscale_access_steadystate_policy_path        = "/testpath/"
  anyscale_access_steadystate_policy_description = "Anyscale TESTPOLICY Description"

  anyscale_custom_policy_name        = "anyscale-custom-policy-testpolicy"
  anyscale_custom_policy_path        = "/testcustompath/"
  anyscale_custom_policy_description = "Anyscale CUSTOM TESTPOLICY Description"
  anyscale_custom_policy             = data.aws_iam_policy_document.anyscale_custom_policy.json

  anyscale_access_managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
  ]

  create_cluster_node_instance_profile   = true
  anyscale_cluster_node_role_name        = "anyscale-cluster-node-role-testrole"
  anyscale_cluster_node_role_path        = "/testclusternodepath/"
  anyscale_cluster_node_role_description = "Anyscale Cluster Node TESTROLE Description"

  anyscale_cluster_node_custom_policy_name        = "anyscale-cluster-node-policy-testpolicy"
  anyscale_cluster_node_custom_policy_path        = "/testclusternodepath/"
  anyscale_cluster_node_custom_policy_description = "Anyscale Cluster Node CUSTOM TESTPOLICY Description"
  anyscale_cluster_node_custom_policy             = data.aws_iam_policy_document.anyscale_cluster_node_custom_policy.json

  anyscale_cluster_node_managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonGlacierReadOnlyAccess"
  ]

  tags = local.full_tags
}

data "aws_iam_policy_document" "anyscale_custom_policy" {
  statement {
    sid       = "testpolicy"
    effect    = "Allow"
    actions   = ["ec2:DescribeRegions"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "anyscale_cluster_node_custom_policy" {
  statement {
    sid       = "testpolicy"
    effect    = "Allow"
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Do not create any resources
# ---------------------------------------------------------------------------------------------------------------------
module "test_no_resources" {
  source = "../.."

  module_enabled = false
}
